namespace coff.API.SharedKernel.Domain.Categories;

public sealed record CategoryCreatedDomainEvent(Guid AccountId) : IDomainEvent;
