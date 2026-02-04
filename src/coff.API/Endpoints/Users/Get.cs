using coff.API.Abstractions.Messaging;
using coff.API.Endpoints.Shared;
using coff.API.Features.Users.Queries.Get;
using coff.API.SharedKernel;
using coff.API.Extensions;
using coff.API.Features.Users.Queries;
using coff.API.SharedKernel.Infrastructure;

namespace coff.API.Endpoints.Users;

internal sealed class Get : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("users/me", async (
            IQueryHandler<GetUsersQuery, UserResponse> handler,
            CancellationToken cancellationToken) =>
        {
            var query = new GetUsersQuery();

            Result<UserResponse> result = await handler.Handle(query, cancellationToken);

            return result.Match(Results.Ok, CustomResults.Problem);
        })
        .HasPermission(Permissions.UsersAccess)
        .WithTags(Tags.Users);
    }
}
