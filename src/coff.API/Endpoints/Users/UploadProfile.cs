using coff.API.Abstractions.Messaging;
using coff.API.Endpoints.Shared;
using coff.API.SharedKernel;
using coff.API.Extensions;
using coff.API.Features.Users.Commands.UploadProfile;
using coff.API.SharedKernel.Infrastructure;
using Microsoft.AspNetCore.Mvc;

namespace coff.API.Endpoints.Users;

internal sealed class UploadProfile : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("users/me/profile-image", async (
            IFormFile file,
            ICommandHandler<UploadProfileImageCommand, Guid> handler,
            CancellationToken cancellationToken) =>
            {
                using Stream stream = file.OpenReadStream();

                var command = new UploadProfileImageCommand(stream, file.ContentType);

            Result<Guid> result = await handler.Handle(command, cancellationToken);

            return result.Match(fileId => Results.Ok(new { fileId }), CustomResults.Problem);
        })
        .WithTags(Tags.Users)
        .RequireAuthorization()
        .DisableAntiforgery();
    }
}
