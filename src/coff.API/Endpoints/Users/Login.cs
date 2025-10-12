using coff.API.Abstractions.Messaging;
using coff.API.Extensions;
using coff.API.SharedKernel.Infrastructure;
using coff.API.Endpoints.Shared;
using coff.API.Features.Users.Commands.Login;
using coff.API.SharedKernel;

namespace coff.API.Endpoints.Users;

internal sealed class Login : IEndpoint
{
    public sealed record Request(string Email, string Password);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("users/login",
            async (Request request,
                ICommandHandler<LoginUserCommand, string> handler,
                CancellationToken cancellationToken) =>
            {
                var command = new LoginUserCommand(
                    request.Email,
                    request.Password);
                
                Result<string> result = await handler.Handle(command, cancellationToken);
                
                return result.Match(Results.Ok, CustomResults.Problem);
            })
            .WithTags(Tags.Users);
    }
}
