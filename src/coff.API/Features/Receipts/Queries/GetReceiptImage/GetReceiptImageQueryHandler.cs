using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.Abstractions.Storage;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Receipts;
using coff.API.SharedKernel.Domain.Users;
using coff.API.SharedKernel.Infrastructure.Storage;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Receipts.Queries.GetReceiptImage;

internal sealed class GetReceiptImageQueryHandler(
    IApplicationDbContext context,
    IUserContext userContext,
    IBlobService blobService)
    : IQueryHandler<GetReceiptImageQuery, FileResponse>
{
    public async Task<Result<FileResponse>> Handle(
        GetReceiptImageQuery query,
        CancellationToken cancellationToken)
    {
        if (!userContext.IsAuthenticated)
        {
            return Result.Failure<FileResponse>(UserErrors.Unauthorized());
        }

        Guid? imageId = await context.Receipts
            .AsNoTracking()
            .Where(r => r.Id == query.ReceiptId && r.UserId == userContext.UserId)
            .Select(r => (Guid?)r.ImageId)
            .SingleOrDefaultAsync(cancellationToken);

        if (imageId is null)
        {
            return Result.Failure<FileResponse>(ReceiptErrors.NotFound(query.ReceiptId));
        }

        FileResponse file = await blobService.DownloadAsync(
            BlobContainers.Receipts,
            userContext.UserId,
            imageId.Value,
            cancellationToken);

        return file;
    }
}
