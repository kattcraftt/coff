namespace coff.API.SharedKernel.Domain.Accounts;

public sealed record AccountCreatedDomainEvent(Guid AccountId) : IDomainEvent;
