using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Accounts;
using coff.API.SharedKernel.Domain.Users;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Users.Commands.ChangePassword;

internal sealed class ChangePasswordCommandHandler(
    UserManager<User> userManager,
    IUserContext userContext) 
    : ICommandHandler<ChangePasswordCommand>
{
    public async Task<Result> Handle(ChangePasswordCommand command, CancellationToken cancellationToken)
    {
        Guid currentUserId = userContext.UserId;
        
        User? user = await userManager.FindByIdAsync(currentUserId.ToString());

        if (user is null)
        {
            return Result.Failure(UserErrors.NotFound(currentUserId));
        }
        
        IdentityResult passwordResult = await userManager.ChangePasswordAsync(
            user,
            command.OldPassword!,
            command.NewPassword!);

        if (!passwordResult.Succeeded)
        {
            return Result.Failure(
                passwordResult.Errors
                .Select(e => Error.Problem(e.Code, e.Description))
                .ToList());
        }

        return Result.Success();
    }
}
