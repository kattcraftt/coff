using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Analytics.Queries.GetOverview;

public sealed record GetOverviewQuery(DateOnly From, DateOnly To, Guid? AccountId)
    : IQuery<GetOverviewResponse>;
