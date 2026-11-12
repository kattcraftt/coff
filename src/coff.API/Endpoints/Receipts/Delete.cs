using coff.API.Abstractions.Messaging;
using coff.API.Endpoints.Shared;
using coff.API.Extensions;
using coff.API.Features.Receipts.Commands.DeleteReceipt;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Infrastructure;

namespace coff.API.Endpoints.Receipts;

internal sealed class Delete : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapDelete("receipts/{id:guid}", async (
                Guid id,
                ICommandHandler<DeleteReceiptCommand> handler,
                CancellationToken cancellationToken) =>
            {
                Result result = await handler.Handle(new DeleteReceiptCommand(id), cancellationToken);

                return result.Match(Results.NoContent, CustomResults.Problem);
            })
            .WithTags(Tags.Receipts)
            .RequireAuthorization();
    }
}
