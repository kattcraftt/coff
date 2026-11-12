using coff.API.Abstractions.Messaging;
using coff.API.Endpoints.Shared;
using coff.API.Extensions;
using coff.API.Features.Receipts.Queries;
using coff.API.Features.Receipts.Queries.GetReceipts;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Infrastructure;

namespace coff.API.Endpoints.Receipts;

internal sealed class Get : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("receipts", async (
                IQueryHandler<GetReceiptsQuery, List<ReceiptResponse>> handler,
                CancellationToken cancellationToken) =>
            {
                Result<List<ReceiptResponse>> result =
                    await handler.Handle(new GetReceiptsQuery(), cancellationToken);

                return result.Match(Results.Ok, CustomResults.Problem);
            })
            .WithTags(Tags.Receipts)
            .RequireAuthorization();
    }
}
