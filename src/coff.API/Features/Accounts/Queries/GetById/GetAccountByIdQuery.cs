using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Accounts.Queries.GetById;

public sealed record GetAccountByIdQuery(Guid AccountId, Guid UserId) : IQuery<AccountResponse>;
