using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Categories;
using coff.API.SharedKernel.Domain.Transactions;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Transactions.Commands.DeleteTransaction;

internal sealed class DeleteTransactionCommandHandler(
    IApplicationDbContext context,
    IUserContext userContext)
    : ICommandHandler<DeleteTransactionCommand>
{
    public async Task<Result> Handle(DeleteTransactionCommand command, CancellationToken cancellationToken)
    {
        Transaction? transaction = await context.Transactions
            .SingleOrDefaultAsync(t => t.Id == command.TransactionId && t.Account.UserId == userContext.UserId, cancellationToken);

        if (transaction is null)
        {
            return Result.Failure(CategoryErrors.NotFound(command.TransactionId));
        }

        context.Transactions.Remove(transaction);
        
        transaction.Raise(new CategoryDeletedDomainEvent(transaction.Id));

        await context.SaveChangesAsync(cancellationToken);
        
        return Result.Success();
    }
}
