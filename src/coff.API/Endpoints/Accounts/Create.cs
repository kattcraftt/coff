using coff.API.Abstractions.Messaging;
using coff.API.Endpoints.Shared;
using coff.API.Features.Accounts.Commands.CreateAccount;
using coff.API.SharedKernel.Domain.Accounts;
using coff.API.SharedKernel;
using coff.API.Extensions;
using coff.API.SharedKernel.Infrastructure;

namespace coff.API.Endpoints.Accounts;

internal sealed class Create : IEndpoint
{
    public sealed record Request(string Name, Guid UserId);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("accounts", async (
            Request request,
            ICommandHandler<CreateAccountCommand, Guid> handler,
            CancellationToken cancellationToken) =>
        {
            var command = new CreateAccountCommand(
                request.Name, request.UserId);

            Result<Guid> result = await handler.Handle(command, cancellationToken);

            return result.Match(Results.Ok, CustomResults.Problem);
        })
        .WithTags(Tags.Accounts)
        .RequireAuthorization();
    }
}
