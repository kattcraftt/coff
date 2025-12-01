using coff.API.Abstractions.Messaging;
using coff.API.Endpoints.Shared;
using coff.API.SharedKernel;
using coff.API.Extensions;
using coff.API.Features.Transactions.Commands.UpdateTransaction;
using coff.API.SharedKernel.Infrastructure;

namespace coff.API.Endpoints.Transactions;

internal sealed class Update : IEndpoint
{
    public sealed record Request(decimal Amount, string Payee, string Notes);
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPut("transactions/{id:guid}", async (
            Guid id,    
            Request request,
            ICommandHandler<UpdateTransactionCommand> handler,
            CancellationToken cancellationToken) =>
        {
            var command = new UpdateTransactionCommand()
            {
                TransactionId = id,
                Amount = request.Amount,
                Payee = request.Payee,
                Notes = request.Notes
            };

            Result result = await handler.Handle(command, cancellationToken);

            return result.Match(Results.NoContent, CustomResults.Problem);
        })
        .WithTags(Tags.Categories)
        .RequireAuthorization();
    }
}
