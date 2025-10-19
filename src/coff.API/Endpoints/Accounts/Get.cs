using coff.API.Abstractions.Messaging;
using coff.API.Endpoints.Shared;
using coff.API.Features.Accounts.Queries.GetAccounts;
using coff.API.Features.Accounts.Queries;
using coff.API.SharedKernel;
using coff.API.Extensions;
using coff.API.SharedKernel.Infrastructure;

namespace coff.API.Endpoints.Accounts;

internal sealed class Get : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("accounts", async (
            IQueryHandler<GetAccountsQuery, List<AccountResponse>> handler,
            CancellationToken cancellationToken) =>
        {
            var query = new GetAccountsQuery();

            Result<List<AccountResponse>> result = await handler.Handle(query, cancellationToken);

            return result.Match(Results.Ok, CustomResults.Problem);
        })
        .WithTags(Tags.Accounts)
        .RequireAuthorization();
    }
}
