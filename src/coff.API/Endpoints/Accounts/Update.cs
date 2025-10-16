using coff.API.Abstractions.Messaging;
using coff.API.Endpoints.Shared;
using coff.API.Features.Accounts.Commands.UpdateAccount;
using coff.API.SharedKernel;
using coff.API.Extensions;
using coff.API.SharedKernel.Infrastructure;
using Microsoft.AspNetCore.Mvc;

namespace coff.API.Endpoints.Accounts;

internal sealed class Update : IEndpoint
{
    public sealed record Request(string Name);
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPut("accounts/{id:guid}", async (
            Guid id,    
            [FromBody] Request request,
            ICommandHandler<UpdateAccountCommand> handler,
            CancellationToken cancellationToken) =>
        {
            var command = new UpdateAccountCommand(id, request.Name);

            Result result = await handler.Handle(command, cancellationToken);

            return result.Match(Results.NoContent, CustomResults.Problem);
        })
        .WithTags(Tags.Accounts)
        .RequireAuthorization();
    }
}
