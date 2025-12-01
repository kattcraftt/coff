using coff.API.Abstractions.Messaging;
using coff.API.Endpoints.Shared;
using coff.API.SharedKernel;
using coff.API.Extensions;
using coff.API.Features.Transactions.Commands.CreateTransaction;
using coff.API.SharedKernel.Infrastructure;

namespace coff.API.Endpoints.Transactions;

internal sealed class Create : IEndpoint
{
    public sealed record Request(decimal Amount, string Payee, string Notes, DateTime Date);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("transactions", async (
            Request request,
            ICommandHandler<CreateTransactionCommand, Guid> handler,
            CancellationToken cancellationToken) =>
            {
                var command = new CreateTransactionCommand()
                {
                   Amount = request.Amount, 
                   Payee = request.Payee, 
                   Notes = request.Notes, 
                   Date = request.Date,
                };
                

            Result<Guid> result = await handler.Handle(command, cancellationToken);

            return result.Match(Results.Ok, CustomResults.Problem);
        })
        .WithTags(Tags.Transactions)
        .RequireAuthorization();
    }
}
