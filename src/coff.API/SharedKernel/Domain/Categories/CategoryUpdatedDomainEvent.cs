namespace coff.API.SharedKernel.Domain.Categories;

public sealed record CategoryUpdatedDomainEvent(Guid AccountId) : IDomainEvent;
