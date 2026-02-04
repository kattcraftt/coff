using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Messaging;
using coff.API.Abstractions.Storage;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Users;
using coff.API.SharedKernel.Infrastructure.Storage;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Options;

namespace coff.API.Features.Users.Queries.DisplayProfile;

internal sealed class DisplayProfileImageQueryHandler(
    UserManager<User> userManager,
    IBlobService blobService,
    IUserContext userContext)
    : IQueryHandler<DisplayProfileImageQuery, FileResponse>
{
    public async Task<Result<FileResponse>> Handle(DisplayProfileImageQuery query, CancellationToken cancellationToken)
    {
        Guid userId = userContext.UserId;
        User? user = await userManager.FindByIdAsync(userId.ToString());
        
        if (user is null)
        {
            return Result.Failure<FileResponse>(UserErrors.NotFound(userId));
        }
        FileResponse file = await blobService.DownloadAsync(
            BlobContainers.ProfileImages,
            userId,
            user.ProfileImageId!.Value,
            cancellationToken);

        return file;
    }
}
