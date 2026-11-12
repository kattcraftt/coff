using coff.API.Abstractions.Messaging;
using coff.API.Endpoints.Shared;
using coff.API.Extensions;
using coff.API.Features.Receipts.Commands.ConfirmReceipt;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Infrastructure;

namespace coff.API.Endpoints.Receipts;

internal sealed class Confirm : IEndpoint
{
    public sealed record Request(
        Guid AccountId,
        Guid CategoryId,
        decimal Amount,
        string Payee,
        string? Notes,
        DateTime Date);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("receipts/{id:guid}/confirm", async (
                Guid id,
                Request request,
                ICommandHandler<ConfirmReceiptCommand, Guid> handler,
                CancellationToken cancellationToken) =>
            {
                var command = new ConfirmReceiptCommand
                {
                    ReceiptId = id,
                    AccountId = request.AccountId,
                    CategoryId = request.CategoryId,
                    Amount = request.Amount,
                    Payee = request.Payee,
                    Notes = request.Notes,
                    Date = request.Date
                };

                Result<Guid> result = await handler.Handle(command, cancellationToken);

                return result.Match(Results.Ok, CustomResults.Problem);
            })
            .WithTags(Tags.Receipts)
            .RequireAuthorization();
    }
}
