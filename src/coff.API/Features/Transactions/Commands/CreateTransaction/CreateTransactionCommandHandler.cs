using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Transactions;
using coff.API.SharedKernel.Domain.Users;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Transactions.Commands.CreateTransaction;

internal sealed class CreateTransactionCommandHandler(
    IApplicationDbContext context,
    IUserContext userContext)
    : ICommandHandler<CreateTransactionCommand, Guid>
{
    public async Task<Result<Guid>> Handle(CreateTransactionCommand command, CancellationToken cancellationToken)
    {
        if (!userContext.IsAuthenticated)
        {
            return Result.Failure<Guid>(UserErrors.Unauthorized());
        }

        // The account and category must belong to the signed-in user.
        bool accountExists = await context.Accounts
            .AnyAsync(
                a => a.Id == command.AccountId && a.UserId == userContext.UserId,
                cancellationToken);
        if (!accountExists)
        {
            return Result.Failure<Guid>(TransactionErrors.AccountNotFound(command.AccountId));
        }

        bool categoryExists = await context.Categories
            .AnyAsync(
                c => c.Id == command.CategoryId && c.UserId == userContext.UserId,
                cancellationToken);
        if (!categoryExists)
        {
            return Result.Failure<Guid>(TransactionErrors.CategoryNotFound(command.CategoryId));
        }

        var transaction = new Transaction
        {
            Id = Guid.NewGuid(),
            Amount = command.Amount,
            Payee = command.Payee,
            Notes = command.Notes,
            Date = command.Date,
            AccountId = command.AccountId,
            CategoryId = command.CategoryId
        };

        transaction.Raise(new TransactionCreatedDomainEvent(transaction.Id));

        context.Transactions.Add(transaction);

        await context.SaveChangesAsync(cancellationToken);

        return transaction.Id;
    }
}
