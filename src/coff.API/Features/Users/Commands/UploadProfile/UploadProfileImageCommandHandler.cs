using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Messaging;
using coff.API.Abstractions.Storage;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Users;
using coff.API.SharedKernel.Infrastructure.Storage;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Options;

namespace coff.API.Features.Users.Commands.UploadProfile;

internal sealed class UploadProfileImageCommandHandler(
    UserManager<User> userManager,
    IBlobService blobService,
    IUserContext userContext)
    : ICommandHandler<UploadProfileImageCommand, Guid>
{
    public async Task<Result<Guid>> Handle(UploadProfileImageCommand command, CancellationToken cancellationToken)
    {
        Guid userId = userContext.UserId;
        User? user = await userManager.FindByIdAsync(userId.ToString());
        
        if (user is null)
        {
            return Result.Failure<Guid>(UserErrors.NotFound(userId));
        }

        Guid fileid = await blobService.UploadAsync(
            command.Stream,
            command.ContentType,
            BlobContainers.ProfileImages,
            userId,
            cancellationToken
            );

        if (user.ProfileImageId is not null)
        {
            await blobService.DeleteAsync(
                BlobContainers.ProfileImages,
                userId,
                user.ProfileImageId.Value,
                cancellationToken
                );
        }

        user.ProfileImageId = fileid;
        
        await userManager.UpdateAsync(user);

        return fileid;
    }
}
