using coff.API.Abstractions.Messaging;
using coff.API.Features.Users.Commands.Register;
using coff.API.Extensions;
using coff.API.SharedKernel.Infrastructure;
using coff.API.Endpoints.Shared;
using coff.API.SharedKernel;

namespace coff.API.Endpoints.Users;

internal sealed class Register : IEndpoint
{
    public sealed record Request(string Email, string Password, string ConfirmPassword);

    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("users/register",
            async (Request request,
                ICommandHandler<RegisterUserCommand, Guid> handler,
                CancellationToken cancellationToken) =>
            {
                var command = new RegisterUserCommand(
                    request.Email,
                    request.Password,
                    request.ConfirmPassword);
                
                Result<Guid> result = await handler.Handle(command, cancellationToken);
                
                return result.Match(Results.Ok, CustomResults.Problem);
            })
            .WithTags(Tags.Users);
    }
}
