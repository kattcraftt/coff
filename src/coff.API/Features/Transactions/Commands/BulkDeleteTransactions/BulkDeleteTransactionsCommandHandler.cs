using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Transactions;
using coff.API.SharedKernel.Domain.Users;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Transactions.Commands.BulkDeleteTransactions;

internal sealed class BulkDeleteTransactionsCommandHandler(
    IApplicationDbContext context,
    IUserContext userContext)
    : ICommandHandler<BulkDeleteTransactionsCommand, BulkDeleteTransactionsResponse>
{
    public async Task<Result<BulkDeleteTransactionsResponse>> Handle(
        BulkDeleteTransactionsCommand command,
        CancellationToken cancellationToken)
    {
        if (!userContext.IsAuthenticated)
        {
            return Result.Failure<BulkDeleteTransactionsResponse>(UserErrors.Unauthorized());
        }

        // Only the signed-in user's own transactions can match (they belong to a user through their account).
        List<Transaction> transactions = await context.Transactions
            .Where(t => command.Ids.Contains(t.Id) && t.Account.UserId == userContext.UserId)
            .ToListAsync(cancellationToken);

        foreach (Transaction transaction in transactions)
        {
            transaction.Raise(new TransactionDeletedDomainEvent(transaction.Id));
        }

        context.Transactions.RemoveRange(transactions);

        // One SaveChanges: all of them are deleted, or none.
        await context.SaveChangesAsync(cancellationToken);

        return new BulkDeleteTransactionsResponse(transactions.Count);
    }
}
