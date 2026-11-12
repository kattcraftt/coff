using coff.API.Abstractions.Messaging;
using coff.API.Endpoints.Shared;
using coff.API.Extensions;
using coff.API.Features.Receipts.Queries;
using coff.API.Features.Receipts.Queries.GetReceiptById;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Infrastructure;

namespace coff.API.Endpoints.Receipts;

internal sealed class GetById : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("receipts/{id:guid}", async (
                Guid id,
                IQueryHandler<GetReceiptByIdQuery, ReceiptResponse> handler,
                CancellationToken cancellationToken) =>
            {
                Result<ReceiptResponse> result =
                    await handler.Handle(new GetReceiptByIdQuery(id), cancellationToken);

                return result.Match(Results.Ok, CustomResults.Problem);
            })
            .WithTags(Tags.Receipts)
            .RequireAuthorization();
    }
}
