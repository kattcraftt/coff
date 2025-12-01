using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Transactions.Queries.GetTransactions;

internal sealed class GetTransactionsQueryHandler(IApplicationDbContext context, IUserContext userContext)
    : IQueryHandler<GetTransactionsQuery, List<TransactionResponse>>
{
    public async Task<Result<List<TransactionResponse>>> Handle(GetTransactionsQuery query, CancellationToken cancellationToken)
    {
        List<TransactionResponse> transactions = await context.Transactions
            .Where(t => t.Account.UserId == userContext.UserId)
            .Include(t => t.Account)
            .Include(t => t.Category)
            .Select(t => new TransactionResponse
            {
                Id = t.Id,
                Amount = t.Amount,
                Payee = t.Payee,
                Notes = t.Notes,
                Date = t.Date
            })
            .ToListAsync(cancellationToken);
        
        return transactions;
    }
}
