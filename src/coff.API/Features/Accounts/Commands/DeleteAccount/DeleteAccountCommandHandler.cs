using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Accounts;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Accounts.Commands.DeleteAccount;

internal sealed class DeleteAccountCommandHandler(
    IApplicationDbContext context,
    IUserContext userContext)
    : ICommandHandler<DeleteAccountCommand>
{
    public async Task<Result> Handle(DeleteAccountCommand command, CancellationToken cancellationToken)
    {
        Account? account = await context.Accounts
            .SingleOrDefaultAsync(a => a.Id == command.AccountId && a.UserId == userContext.UserId, cancellationToken);

        if (account is null)
        {
            return Result.Failure(AccountErrors.NotFound(command.AccountId));
        }

        context.Accounts.Remove(account);
        
        account.Raise(new AccountDeletedDomainEvent(account.Id));

        await context.SaveChangesAsync(cancellationToken);
        
        return Result.Success();
    }
}
