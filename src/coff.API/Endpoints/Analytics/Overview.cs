using coff.API.Abstractions.Messaging;
using coff.API.Endpoints.Shared;
using coff.API.Extensions;
using coff.API.Features.Analytics.Queries.GetOverview;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Infrastructure;
using Microsoft.AspNetCore.Mvc;

namespace coff.API.Endpoints.Analytics;

internal sealed class Overview : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        // GET analytics/overview?from=2026-10-01&to=2026-10-31&accountId=<optional guid>
        app.MapGet("analytics/overview", async (
                [FromQuery(Name = "from")] DateOnly fromDate,
                [FromQuery(Name = "to")] DateOnly toDate,
                Guid? accountId,
                IQueryHandler<GetOverviewQuery, GetOverviewResponse> handler,
                CancellationToken cancellationToken) =>
            {
                Result<GetOverviewResponse> result = await handler.Handle(
                    new GetOverviewQuery(fromDate, toDate, accountId),
                    cancellationToken);

                return result.Match(Results.Ok, CustomResults.Problem);
            })
            .WithTags(Tags.Analytics)
            .RequireAuthorization();
    }
}
