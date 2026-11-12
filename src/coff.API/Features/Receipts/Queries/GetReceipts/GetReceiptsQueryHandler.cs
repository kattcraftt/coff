using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Receipts;
using coff.API.SharedKernel.Domain.Users;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Receipts.Queries.GetReceipts;

internal sealed class GetReceiptsQueryHandler(
    IApplicationDbContext context,
    IUserContext userContext)
    : IQueryHandler<GetReceiptsQuery, List<ReceiptResponse>>
{
    public async Task<Result<List<ReceiptResponse>>> Handle(
        GetReceiptsQuery query,
        CancellationToken cancellationToken)
    {
        if (!userContext.IsAuthenticated)
        {
            return Result.Failure<List<ReceiptResponse>>(UserErrors.Unauthorized());
        }

        List<ReceiptResponse> receipts = await context.Receipts
            .AsNoTracking()
            .Where(r => r.UserId == userContext.UserId)
            .OrderByDescending(r => r.CreatedAtUtc)
            .Select(r => new ReceiptResponse(
                r.Id,
                r.Merchant,
                r.Date,
                r.Total,
                r.Tax,
                r.Currency,
                r.Status == ReceiptStatus.Confirmed ? "Confirmed" : "Pending",
                r.TransactionId))
            .ToListAsync(cancellationToken);

        return receipts;
    }
}
