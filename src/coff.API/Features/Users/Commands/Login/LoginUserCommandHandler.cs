using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Users;
using Microsoft.AspNetCore.Identity;

namespace coff.API.Features.Users.Login;

internal sealed class LoginUserCommandHandler(
    UserManager<User> userManager,
    SignInManager<User> signInManager,
    ITokenProvider tokenProvider) : ICommandHandler<LoginUserCommand, string>
{
    public async Task<Result<string>> Handle(LoginUserCommand command, CancellationToken cancellationToken)
    {
        User? user = await userManager.FindByEmailAsync(command.Email);

        if (user is null)
        {
            return Result.Failure<string>(UserErrors.NotFoundByEmail);
        }

       SignInResult verified = await signInManager.CheckPasswordSignInAsync(user, command.Password, lockoutOnFailure: false);

        if (!verified.Succeeded)
        {
            return Result.Failure<string>(UserErrors.InvalidCredentials);
        }

        string token = tokenProvider.Create(user);

        return Result.Success(token);
    }
}
