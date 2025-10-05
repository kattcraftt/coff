using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Accounts;
using coff.API.SharedKernel.Domain.Users;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Accounts.Commands.CreateAccount;

internal sealed class CreateAccountCommandHandler(
    UserManager<User> userManager,
    IApplicationDbContext context,
    IUserContext userContext) 
    : ICommandHandler<CreateAccountCommand, Guid>
{
    public async Task<Result<Guid>> Handle(CreateAccountCommand command, CancellationToken cancellationToken)
    {
        if (userContext.UserId != command.UserId)
        {
            return Result.Failure<Guid>(UserErrors.Unauthorized());
        }

        User? user = await userManager.Users.AsNoTracking()
            .SingleOrDefaultAsync(u => u.Id == command.UserId, cancellationToken);

        if (user is null)
        {
            return Result.Failure<Guid>(UserErrors.NotFound(command.UserId));
        }

        var account = new Account
        {
            UserId = user.Id,
            Name = command.Name
        };
        
        account.Raise(new AccountCreatedDomainEvent(account.Id));

        context.Accounts.Add(account);
        
        await context.SaveChangesAsync(cancellationToken);
        
        return account.Id;
    }
}
