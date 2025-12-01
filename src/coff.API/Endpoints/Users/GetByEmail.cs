using coff.API.Abstractions.Messaging;
using coff.API.Endpoints.Shared;
using coff.API.Features.Users.Queries.GetByEmail;
using coff.API.SharedKernel;
using coff.API.Extensions;
using coff.API.Features.Users.Queries;
using coff.API.SharedKernel.Infrastructure;

namespace coff.API.Endpoints.Users;

internal sealed class GetByEmail : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("users/{email}", async (
            string email,
            IQueryHandler<GetUserByEmailQuery, UserResponse> handler,
            CancellationToken cancellationToken) =>
        {
            var query = new GetUserByEmailQuery(email);

            Result<UserResponse> result = await handler.Handle(query, cancellationToken);

            return result.Match(Results.Ok, CustomResults.Problem);
        })
        .HasPermission(Permissions.UsersAccess)
        .WithTags(Tags.Users);
    }
}
