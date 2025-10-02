namespace coff.API.SharedKernel.Domain.Accounts;

public sealed record AccountRegisteredDomainEvent(Guid AccountId) : IDomainEvent;
