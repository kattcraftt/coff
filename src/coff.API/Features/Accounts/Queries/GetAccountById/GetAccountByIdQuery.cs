using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Accounts.Queries.GetAccountById;

public sealed record GetAccountByIdQuery(Guid AccountId) : IQuery<AccountResponse>;
