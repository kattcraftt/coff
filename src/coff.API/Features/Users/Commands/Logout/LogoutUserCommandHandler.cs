using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Users;
using Microsoft.AspNetCore.Identity;

namespace coff.API.Features.Users.Commands.Logout;

internal sealed class LogoutUserCommandHandler(
    SignInManager<User> signInManager) : ICommandHandler<LogoutUserCommand>
{
    public async Task<Result> Handle(LogoutUserCommand command, CancellationToken cancellationToken)
    { 
        await signInManager.SignOutAsync();
        
        return Result.Success();
    }
}
