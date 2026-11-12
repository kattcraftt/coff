using coff.API.Abstractions.Messaging;
using coff.API.Abstractions.Storage;
using coff.API.Endpoints.Shared;
using coff.API.Extensions;
using coff.API.Features.Receipts.Queries.GetReceiptImage;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Infrastructure;

namespace coff.API.Endpoints.Receipts;

internal sealed class Image : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("receipts/{id:guid}/image", async (
                Guid id,
                IQueryHandler<GetReceiptImageQuery, FileResponse> handler,
                CancellationToken cancellationToken) =>
            {
                Result<FileResponse> result = await handler.Handle(
                    new GetReceiptImageQuery(id),
                    cancellationToken);

                return result.Match(
                    file => Results.File(
                        file.Stream,
                        file.ContentType,
                        fileDownloadName: null,
                        enableRangeProcessing: true),
                    CustomResults.Problem);
            })
            .WithTags(Tags.Receipts)
            .RequireAuthorization();
    }
}
