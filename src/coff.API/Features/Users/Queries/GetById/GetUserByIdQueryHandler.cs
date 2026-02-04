using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Messaging;
using coff.API.Abstractions.Storage;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Users;
using coff.API.SharedKernel.Infrastructure.Storage;
using Microsoft.AspNetCore.Identity;

namespace coff.API.Features.Users.Queries.GetById;

internal sealed class GetUserByIdQueryHandler(
    UserManager<User> userManager, 
    IUserContext userContext, 
    IBlobService blobService)
    : IQueryHandler<GetUserByIdQuery, UserResponse>
{
    public async Task<Result<UserResponse>> Handle(GetUserByIdQuery query, CancellationToken cancellationToken)
    {
        if (query.UserId != userContext.UserId)
        {
            return Result.Failure<UserResponse>(UserErrors.Unauthorized());
        }

        User? user = await userManager.FindByIdAsync(query.UserId.ToString());

        if (user is null)
        {
            return Result.Failure<UserResponse>(UserErrors.NotFound(query.UserId));
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
