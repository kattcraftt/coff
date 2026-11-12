using coff.API.Abstractions.Messaging;
using coff.API.Endpoints.Shared;
using coff.API.Extensions;
using coff.API.Features.Receipts.Commands.ScanReceipt;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Infrastructure;

namespace coff.API.Endpoints.Receipts;

internal sealed class Scan : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("receipts/scan", async (
                IFormFile file,
                ICommandHandler<ScanReceiptCommand, ScanReceiptResponse> handler,
                CancellationToken cancellationToken) =>
            {
                await using Stream stream = file.OpenReadStream();

                var command = new ScanReceiptCommand
                {
                    Content = stream,
                    Length = file.Length
                };

                Result<ScanReceiptResponse> result = await handler.Handle(command, cancellationToken);

                return result.Match(Results.Ok, CustomResults.Problem);
            })
            .DisableAntiforgery() // required for IFormFile binding in minimal APIs; auth is bearer-token based
            .WithTags(Tags.Receipts)
            .RequireAuthorization();
    }
}
