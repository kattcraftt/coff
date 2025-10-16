namespace coff.API.SharedKernel.Domain.Accounts;

public sealed record AccountUpdatedDomainEvent(Guid AccountId) : IDomainEvent;
