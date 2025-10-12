using coff.API.Abstractions.Messaging;
using coff.API.Endpoints.Shared;
using coff.API.Features.Accounts.Commands.DeleteAccount;
using coff.API.SharedKernel;
using coff.API.Extensions;
using coff.API.SharedKernel.Infrastructure;

namespace coff.API.Endpoints.Accounts;

internal sealed class Delete : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapDelete("accounts/{id:guid}", async (
            Guid id,
            ICommandHandler<DeleteAccountCommand> handler,
            CancellationToken cancellationToken) =>
        {
            var command = new DeleteAccountCommand(id);

            Result result = await handler.Handle(command, cancellationToken);

            return result.Match(Results.NoContent, CustomResults.Problem);
        })
        .WithTags(Tags.Accounts)
        .RequireAuthorization();
    }
}
