using coff.API.Abstractions.Messaging;
using coff.API.Endpoints.Shared;
using coff.API.SharedKernel;
using coff.API.Extensions;
using coff.API.Features.Users.Commands.ChangePassword;
using coff.API.SharedKernel.Infrastructure;

namespace coff.API.Endpoints.Users;

internal sealed class ChangePassword : IEndpoint
{
    public sealed record Request(
        string OldPassword, 
        string NewPassword);
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("users/me/change-password", async (
            Request request,
            ICommandHandler<ChangePasswordCommand> handler,
            CancellationToken cancellationToken) =>
            {
                var command = new ChangePasswordCommand()
            {
                OldPassword =  request.OldPassword,
                NewPassword =  request.NewPassword
            };

            Result result = await handler.Handle(command, cancellationToken);

            return result.Match(Results.NoContent, CustomResults.Problem);
        })
        .WithTags(Tags.Users)
        .RequireAuthorization();
    }
}
