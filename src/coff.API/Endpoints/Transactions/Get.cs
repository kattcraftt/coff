using coff.API.Abstractions.Messaging;
using coff.API.Endpoints.Shared;
using coff.API.SharedKernel;
using coff.API.Extensions;
using coff.API.Features.Transactions.Queries;
using coff.API.Features.Transactions.Queries.GetTransactions;
using coff.API.SharedKernel.Infrastructure;

namespace coff.API.Endpoints.Transactions;

internal sealed class Get : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("transactions", async (
            IQueryHandler<GetTransactionsQuery, List<TransactionResponse>> handler,
            CancellationToken cancellationToken) =>
        {
            var query = new GetTransactionsQuery();

            Result<List<TransactionResponse>> result = await handler.Handle(query, cancellationToken);

            return result.Match(Results.Ok, CustomResults.Problem);
        })
        .WithTags(Tags.Transactions)
        .RequireAuthorization();
    }
}
