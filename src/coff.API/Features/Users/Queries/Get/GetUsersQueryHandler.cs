using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Users;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Users.Queries.Get;

internal sealed class GetUsersQueryHandler(UserManager<User> userManager, IUserContext userContext)
    : IQueryHandler<GetUsersQuery, List<UserResponse>>
{
    public async Task<Result<List<UserResponse>>> Handle(GetUsersQuery query, CancellationToken cancellationToken)
    {
        if (query.userId != userContext.UserId)
        {
            return Result.Failure<List<UserResponse>>(UserErrors.Unauthorized());
        }
        List<UserResponse> users = await userManager.Users
            .Select(user => new UserResponse
            {
                Id = user.Id,
                FullName = user.FullName,
                Email = user.Email!
            })
            .ToListAsync(cancellationToken);

        return users;
    }
}
