using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Accounts.Queries.Get;

public sealed record GetAccountsQuery(Guid UserId) : IQuery<List<AccountResponse>>;
