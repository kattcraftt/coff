using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Accounts;
using coff.API.SharedKernel.Domain.Users;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Users.Commands.UpdateUser;

internal sealed class UpdateUserCommandHandler(
    UserManager<User> userManager,
    IUserContext userContext) 
    : ICommandHandler<UpdateUserCommand>
{
    public async Task<Result> Handle(UpdateUserCommand command, CancellationToken cancellationToken)
    {
        Guid currentUserId = userContext.UserId;
        
        User? user = await userManager.FindByIdAsync(currentUserId.ToString());

        if (user is null)
        {
            return Result.Failure(UserErrors.NotFound(currentUserId));
        }

        user.FirstName = command.FirstName;
        user.MiddleName = command.MiddleName;
        user.LastName = command.LastName;
        user.PhoneNumber = command.PhoneNumber;

        IdentityResult updateUserResult = await userManager.UpdateAsync(user);

        if (!updateUserResult.Succeeded)
        {
            return Result.Failure(
                updateUserResult.Errors
                    .Select(e => Error.Problem(e.Code, e.Description))
                    .ToList());
        }
        
        return Result.Success();
    }
}
