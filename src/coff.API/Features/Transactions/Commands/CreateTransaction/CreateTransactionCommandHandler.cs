using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Categories;
using coff.API.SharedKernel.Domain.Transactions;
using coff.API.SharedKernel.Domain.Users;

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

        var transaction = new Transaction
        {
            Id = Guid.NewGuid(),
            Amount = command.Amount,
            Payee = command.Payee,
            Notes = command.Notes,
            Date = command.Date,
        };
        
        transaction.Raise(new TransactionCreatedDomainEvent(transaction.Id));

        context.Transactions.Add(transaction);
        
        await context.SaveChangesAsync(cancellationToken);
        
        return transaction.Id;
    }
}
