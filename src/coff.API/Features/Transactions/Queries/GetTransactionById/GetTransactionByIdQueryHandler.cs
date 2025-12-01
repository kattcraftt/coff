using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Categories;
using coff.API.SharedKernel.Domain.Transactions;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Transactions.Queries.GetTransactionById;

internal sealed class GetTransactionByIdQueryHandler(IApplicationDbContext context, IUserContext userContext)
    : IQueryHandler<GetTransactionByIdQuery, TransactionResponse>
{
    public async Task<Result<TransactionResponse>> Handle(GetTransactionByIdQuery query, CancellationToken cancellationToken)
    {
        TransactionResponse? category = await context.Transactions
            .Where(t => t.Id == query.TransactionId && t.Account.UserId == userContext.UserId)
            .Select(t => new TransactionResponse
            {
                Id = t.Id,
                Amount = t.Amount,
                Payee = t.Payee,
                Notes = t.Notes
            })
            .SingleOrDefaultAsync(cancellationToken);

        if (category is null)
        {
            return Result.Failure<TransactionResponse>(TransactionErrors.NotFound(query.TransactionId));
        }
        return category;
    }
}
