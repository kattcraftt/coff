using coff.API.Abstractions.Messaging;
using coff.API.Endpoints.Shared;
using coff.API.SharedKernel;
using coff.API.Extensions;
using coff.API.Features.Transactions.Queries;
using coff.API.Features.Transactions.Queries.GetTransactionById;
using coff.API.SharedKernel.Infrastructure;

namespace coff.API.Endpoints.Transactions;

internal sealed class GetById : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("transactions/{id:guid}", async (
            Guid id,
            IQueryHandler<GetTransactionByIdQuery, TransactionResponse> handler,
            CancellationToken cancellationToken) =>
        {
            var command = new GetTransactionByIdQuery(id);

            Result<TransactionResponse> result = await handler.Handle(command, cancellationToken);

            return result.Match(Results.Ok, CustomResults.Problem);
        })
        .WithTags(Tags.Transactions)
        .RequireAuthorization();
    }
}
