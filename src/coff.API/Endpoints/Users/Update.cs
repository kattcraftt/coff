using coff.API.Abstractions.Messaging;
using coff.API.Endpoints.Shared;
using coff.API.SharedKernel;
using coff.API.Extensions;
using coff.API.Features.Users.Commands.UpdateUser;
using coff.API.SharedKernel.Infrastructure;

namespace coff.API.Endpoints.Users;

internal sealed class Update : IEndpoint
{
    public sealed record Request(
        string FirstName, 
        string? MiddleName, 
        string LastName, 
        string PhoneNumber);
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPut("users/me", async (
            Request request,
            ICommandHandler<UpdateUserCommand> handler,
            CancellationToken cancellationToken) =>
            {
                var command = new UpdateUserCommand()
            {
                FirstName = request.FirstName,
                MiddleName = request.MiddleName,
                LastName = request.LastName,
                PhoneNumber = request.PhoneNumber,
            };

            Result result = await handler.Handle(command, cancellationToken);

            return result.Match(Results.NoContent, CustomResults.Problem);
        })
        .WithTags(Tags.Users)
        .RequireAuthorization();
    }
}
