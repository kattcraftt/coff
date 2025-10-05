using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Accounts;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Accounts.Commands.UpdateAccount;

internal sealed class UpdateAccountCommandHandler(
    IApplicationDbContext context) 
    : ICommandHandler<UpdateAccontCommand>
{
    public async Task<Result> Handle(UpdateAccontCommand command, CancellationToken cancellationToken)
    {
        Account? account = await context.Accounts
            .SingleOrDefaultAsync(a => a.Id == command.AccountId, cancellationToken);

        if (account is null)
        {
            return Result.Failure(AccountErrors.NotFound(command.AccountId));
        }
        
        account.Name = command.Name;
        
        await context.SaveChangesAsync(cancellationToken);
        
        return Result.Success();
    }
}
