using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Accounts.Queries.GetAccounts;

public sealed record GetAccountsQuery() : IQuery<List<AccountResponse>>;
