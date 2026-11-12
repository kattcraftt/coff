using coff.API.Abstractions.Messaging;
using coff.API.Endpoints.Shared;
using coff.API.Extensions;
using coff.API.Features.Transactions.Commands.ImportTransactions;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Infrastructure;

namespace coff.API.Endpoints.Transactions;

internal sealed class Import : IEndpoint
{
    public sealed record Item(DateTime Date, string Payee, decimal Amount, string? Notes);

    public sealed record Request(Guid AccountId, Guid CategoryId, List<Item> Items);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("transactions/import", async (
                Request request,
                ICommandHandler<ImportTransactionsCommand, ImportTransactionsResponse> handler,
                CancellationToken cancellationToken) =>
            {
                var command = new ImportTransactionsCommand
                {
                    AccountId = request.AccountId,
                    CategoryId = request.CategoryId,
                    Items = request.Items
                        .Select(i => new ImportTransactionItem(i.Date, i.Payee, i.Amount, i.Notes))
                        .ToList()
                };

                Result<ImportTransactionsResponse> result = await handler.Handle(command, cancellationToken);

                return result.Match(Results.Ok, CustomResults.Problem);
            })
            .WithTags(Tags.Transactions)
            .RequireAuthorization();
    }
}
