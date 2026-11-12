using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.Abstractions.Receipts;
using coff.API.Abstractions.Storage;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Receipts;
using coff.API.SharedKernel.Domain.Users;
using coff.API.SharedKernel.Infrastructure.Storage;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace coff.API.Features.Receipts.Commands.ScanReceipt;

internal sealed class ScanReceiptCommandHandler(
    IApplicationDbContext context,
    IUserContext userContext,
    IReceiptExtractor extractor,
    IBlobService blobService,
    IDateTimeProvider dateTimeProvider,
    IOptions<ReceiptOptions> options)
    : ICommandHandler<ScanReceiptCommand, ScanReceiptResponse>
{
    public async Task<Result<ScanReceiptResponse>> Handle(
        ScanReceiptCommand command,
        CancellationToken cancellationToken)
    {
        if (!userContext.IsAuthenticated)
        {
            return Result.Failure<ScanReceiptResponse>(UserErrors.Unauthorized());
        }

        // Every scan is a paid AI call, so cap how many one user can do per month.
        DateTime now = dateTimeProvider.UtcNow;
        var monthStart = new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc);
        int scannedThisMonth = await context.Receipts.CountAsync(
            r => r.UserId == userContext.UserId && r.CreatedAtUtc >= monthStart,
            cancellationToken);

        if (scannedThisMonth >= options.Value.MonthlyScanLimit)
        {
            return Result.Failure<ScanReceiptResponse>(
                ReceiptErrors.ScanLimitReached(options.Value.MonthlyScanLimit));
        }

        using var buffer = new MemoryStream();
        await command.Content.CopyToAsync(buffer, cancellationToken);
        byte[] bytes = buffer.ToArray();

        // Never trust the client-supplied Content-Type: sniff the real format.
        string? mediaType = DetectMediaType(bytes);
        if (mediaType is null)
        {
            return Result.Failure<ScanReceiptResponse>(ReceiptErrors.UnsupportedImage());
        }

        Result<ReceiptExtraction> extraction = await extractor.ExtractAsync(bytes, mediaType, cancellationToken);
        if (extraction.IsFailure)
        {
            return Result.Failure<ScanReceiptResponse>(extraction.Error);
        }

        buffer.Position = 0;
        // Receipts are private: the container must be configured with Public = false.
        Guid imageId = await blobService.UploadAsync(
            buffer,
            mediaType,
            BlobContainers.Receipts,
            userContext.UserId,
            cancellationToken);

        ReceiptExtraction data = extraction.Value;

        var receipt = new Receipt
        {
            Id = Guid.NewGuid(),
            UserId = userContext.UserId,
            ImageId = imageId,
            Merchant = data.Merchant,
            Date = data.Date,
            Total = data.Total,
            Tax = data.Tax,
            Currency = data.Currency,
            Status = ReceiptStatus.Pending,
            CreatedAtUtc = dateTimeProvider.UtcNow
        };

        receipt.Raise(new ReceiptScannedDomainEvent(receipt.Id));

        context.Receipts.Add(receipt);

        await context.SaveChangesAsync(cancellationToken);

        return new ScanReceiptResponse(
            receipt.Id,
            receipt.Merchant,
            receipt.Date,
            receipt.Total,
            receipt.Tax,
            receipt.Currency,
            receipt.Status == ReceiptStatus.Confirmed ? "Confirmed" : "Pending");
    }

    private static string? DetectMediaType(byte[] b)
    {
        if (b.Length >= 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF)
        {
            return "image/jpeg";
        }

        if (b.Length >= 8 && b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47)
        {
            return "image/png";
        }

        if (b.Length >= 12
            && b[0] == 'R' && b[1] == 'I' && b[2] == 'F' && b[3] == 'F'
            && b[8] == 'W' && b[9] == 'E' && b[10] == 'B' && b[11] == 'P')
        {
            return "image/webp";
        }

        return null;
    }
}
