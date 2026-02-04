using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Messaging;
using coff.API.Abstractions.Storage;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Users;
using coff.API.SharedKernel.Infrastructure.Storage;
using Microsoft.AspNetCore.Identity;

namespace coff.API.Features.Users.Queries.Get;

internal sealed class GetUsersQueryHandler(
    UserManager<User> userManager, 
    IUserContext userContext, 
    IBlobService blobService)
    : IQueryHandler<GetUsersQuery, UserResponse>
{
    public async Task<Result<UserResponse>> Handle(GetUsersQuery query, CancellationToken cancellationToken)
    {
        Guid? userId = userContext.UserId;
        
        User? user = await userManager.FindByIdAsync(userId.Value.ToString());
        
        if (user is null)
        {
            return Result.Failure<UserResponse>(UserErrors.NotFound(userId.Value));
        }
        
        var response = new UserResponse
        {
            Id = user.Id,
            FullName = user.FullName,
            Email = user.Email!,
            ProfileImageUrl = user.ProfileImageId.HasValue
                ? blobService.GetPublicUrl(BlobContainers.ProfileImages, user.Id, user.ProfileImageId.Value)?
                    .ToString() : null
        };

        return Result.Success(response);
    }
}
