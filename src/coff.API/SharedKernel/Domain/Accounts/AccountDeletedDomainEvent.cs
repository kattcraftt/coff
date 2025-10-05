namespace coff.API.SharedKernel.Domain.Accounts;

public sealed record AccountDeletedDomainEvent(Guid AccountId) : IDomainEvent;
