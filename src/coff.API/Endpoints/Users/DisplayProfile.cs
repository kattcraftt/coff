using coff.API.Abstractions.Messaging;
using coff.API.Abstractions.Storage;
using coff.API.Endpoints.Shared;
using coff.API.Extensions;
using coff.API.Features.Users.Queries.DisplayProfile;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Infrastructure;

namespace coff.API.Endpoints.Users;

internal sealed class DisplayProfile : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("users/me/display-profile-image", async (
                IQueryHandler<DisplayProfileImageQuery, FileResponse> handler,
                CancellationToken cancellationToken) =>
            {
                Result<FileResponse> result = await handler
                    .Handle(new DisplayProfileImageQuery(), cancellationToken);

                return result.Match(
                    file => Results.File(
                        file.Stream, 
                        file.ContentType, 
                        fileDownloadName: null, 
                        enableRangeProcessing: true), 
                    CustomResults.Problem);
            })
            .WithTags(Tags.Users);
    }
}
