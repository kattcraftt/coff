namespace coff.API.SharedKernel.Domain.Categories;

public sealed record CategoryDeletedDomainEvent(Guid AccountId) : IDomainEvent;
