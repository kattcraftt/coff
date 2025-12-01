using coff.API.Abstractions.Messaging;
using coff.API.Extensions;
using coff.API.SharedKernel.Infrastructure;
using coff.API.Endpoints.Shared;
using coff.API.Features.Users.Commands.Logout;
using coff.API.SharedKernel;

namespace coff.API.Endpoints.Users;

internal sealed class Logout : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("users/logout",
            async (
                ICommandHandler<LogoutUserCommand> handler,
                CancellationToken cancellationToken) =>
            {
                var command = new LogoutUserCommand();
                
                Result result = await handler.Handle(command, cancellationToken);
                
                return result.Match(() => Results.Ok(), CustomResults.Problem);
            })
            .WithTags(Tags.Users);
    }
}
