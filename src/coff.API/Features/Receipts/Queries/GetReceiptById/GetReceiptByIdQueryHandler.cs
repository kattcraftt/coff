using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Receipts;
using coff.API.SharedKernel.Domain.Users;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Receipts.Queries.GetReceiptById;

internal sealed class GetReceiptByIdQueryHandler(
    IApplicationDbContext context,
    IUserContext userContext)
    : IQueryHandler<GetReceiptByIdQuery, ReceiptResponse>
{
    public async Task<Result<ReceiptResponse>> Handle(
        GetReceiptByIdQuery query,
        CancellationToken cancellationToken)
    {
        if (!userContext.IsAuthenticated)
        {
            return Result.Failure<ReceiptResponse>(UserErrors.Unauthorized());
        }

        ReceiptResponse? receipt = await context.Receipts
            .AsNoTracking()
            .Where(r => r.Id == query.ReceiptId && r.UserId == userContext.UserId)
            .Select(r => new ReceiptResponse(
                r.Id,
                r.Merchant,
                r.Date,
                r.Total,
                r.Tax,
                r.Currency,
                r.Status == ReceiptStatus.Confirmed ? "Confirmed" : "Pending",
                r.TransactionId))
            .SingleOrDefaultAsync(cancellationToken);

        return receipt is null
            ? Result.Failure<ReceiptResponse>(ReceiptErrors.NotFound(query.ReceiptId))
            : receipt;
    }
}
