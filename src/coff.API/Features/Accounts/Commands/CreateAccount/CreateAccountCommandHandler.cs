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
    IApplicationDbContext context,
    IUserContext userContext) 
    : ICommandHandler<CreateAccountCommand, Guid>
{
    public async Task<Result<Guid>> Handle(CreateAccountCommand command, CancellationToken cancellationToken)
    {
        if (!userContext.IsAuthenticated)
        {
            return Result.Failure<Guid>(UserErrors.Unauthorized());
        }

        var account = new Account
        {
            Id = Guid.NewGuid(),
            Name = command.Name,
            UserId = userContext.UserId
        };
        
        account.Raise(new AccountCreatedDomainEvent(account.Id));

        context.Accounts.Add(account);
        
        await context.SaveChangesAsync(cancellationToken);
        
        return account.Id;
    }
}
