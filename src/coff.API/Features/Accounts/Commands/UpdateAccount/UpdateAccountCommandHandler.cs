using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Accounts;
using coff.API.SharedKernel.Domain.Users;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Accounts.Commands.UpdateAccount;

internal sealed class UpdateAccountCommandHandler(
    IApplicationDbContext context,
    IUserContext userContext) 
    : ICommandHandler<UpdateAccountCommand>
{
    public async Task<Result> Handle(UpdateAccountCommand command, CancellationToken cancellationToken)
    {
        Account? account = await context.Accounts
            .SingleOrDefaultAsync(a => a.Id == command.AccountId && a.UserId == userContext.UserId, cancellationToken);

        if (account is null)
        {
            return Result.Failure(AccountErrors.NotFound(command.AccountId));
        }
        
        account.Name = command.Name;
        
        account.Raise(new AccountUpdatedDomainEvent(account.Id));
        
        await context.SaveChangesAsync(cancellationToken);
        
        return Result.Success();
    }
}
