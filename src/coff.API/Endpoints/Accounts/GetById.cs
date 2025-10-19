using coff.API.Abstractions.Messaging;
using coff.API.Endpoints.Shared;
using coff.API.Features.Accounts.Queries.GetAccountById;
using coff.API.Features.Accounts.Queries;
using coff.API.SharedKernel;
using coff.API.Extensions;
using coff.API.SharedKernel.Infrastructure;

namespace coff.API.Endpoints.Accounts;

internal sealed class GetById : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("accounts/{id:guid}", async (
            Guid id,
            IQueryHandler<GetAccountByIdQuery, AccountResponse> handler,
            CancellationToken cancellationToken) =>
        {
            var command = new GetAccountByIdQuery(id);

            Result<AccountResponse> result = await handler.Handle(command, cancellationToken);

            return result.Match(Results.Ok, CustomResults.Problem);
        })
        .WithTags(Tags.Accounts)
        .RequireAuthorization();
    }
}
