using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Transactions;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Transactions.Commands.UpdateTransaction;

internal sealed class UpdateTransactionCommandHandler(
    IApplicationDbContext context,
    IUserContext userContext) 
    : ICommandHandler<UpdateTransactionCommand>
{
    public async Task<Result> Handle(UpdateTransactionCommand command, CancellationToken cancellationToken)
    {
        Transaction? transaction = await context.Transactions
            .SingleOrDefaultAsync(t => t.Id == command.TransactionId && t.Account.UserId == userContext.UserId, cancellationToken);

        if (transaction is null)
        {
            return Result.Failure(TransactionErrors.NotFound(command.TransactionId));
        }
        
        // The new account and category must belong to the signed-in user too.
        bool accountExists = await context.Accounts
            .AnyAsync(
                a => a.Id == command.AccountId && a.UserId == userContext.UserId,
                cancellationToken);
        if (!accountExists)
        {
            return Result.Failure(TransactionErrors.AccountNotFound(command.AccountId));
        }

        bool categoryExists = await context.Categories
            .AnyAsync(
                c => c.Id == command.CategoryId && c.UserId == userContext.UserId,
                cancellationToken);
        if (!categoryExists)
        {
            return Result.Failure(TransactionErrors.CategoryNotFound(command.CategoryId));
        }

        transaction.AccountId = command.AccountId;
        transaction.CategoryId = command.CategoryId;
        transaction.Amount = command.Amount;
        transaction.Payee = command.Payee;
        transaction.Notes = command.Notes;
        transaction.Date = command.Date;
        
        transaction.Raise(new TransactionUpdatedDomainEvent(transaction.Id));
        
        await context.SaveChangesAsync(cancellationToken);
        
        return Result.Success();
    }
}
