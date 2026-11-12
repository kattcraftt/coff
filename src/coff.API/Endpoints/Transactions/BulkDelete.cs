using coff.API.Abstractions.Messaging;
using coff.API.Endpoints.Shared;
using coff.API.Extensions;
using coff.API.Features.Transactions.Commands.BulkDeleteTransactions;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Infrastructure;

namespace coff.API.Endpoints.Transactions;

internal sealed class BulkDelete : IEndpoint
{
    public sealed record Request(List<Guid> Ids);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("transactions/bulk-delete", async (
            Request request,
            ICommandHandler<BulkDeleteTransactionsCommand, BulkDeleteTransactionsResponse> handler,
            CancellationToken cancellationToken) =>
        {
            var command = new BulkDeleteTransactionsCommand { Ids = request.Ids };

            Result<BulkDeleteTransactionsResponse> result = await handler.Handle(command, cancellationToken);

            return result.Match(Results.Ok, CustomResults.Problem);
        })
        .WithTags(Tags.Transactions)
        .RequireAuthorization();
    }
}
