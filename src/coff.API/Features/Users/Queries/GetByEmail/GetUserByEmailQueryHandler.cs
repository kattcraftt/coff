using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Users;
using Microsoft.AspNetCore.Identity;

namespace coff.API.Features.Users.Queries.GetByEmail;

internal sealed class GetUserByEmailQueryHandler(UserManager<User> userManager, IUserContext userContext)
    : IQueryHandler<GetUserByEmailQuery, UserResponse>
{
    public async Task<Result<UserResponse>> Handle(GetUserByEmailQuery query, CancellationToken cancellationToken)
    {
        User? user = await userManager.FindByEmailAsync(query.Email);

        if (user is null)
        {
            return Result.Failure<UserResponse>(UserErrors.NotFoundByEmail);
        }

        if (user.Id != userContext.UserId)
        {
            return Result.Failure<UserResponse>(UserErrors.Unauthorized());
        }

        var response = new UserResponse
        {
            Id = user.Id,
            FullName = user.FullName,
            Email = user.Email!
        };

        return Result.Success(response);
    }
}
