namespace coff.API.SharedKernel.Domain.Categories;

public sealed record CategoryUpdatedDomainEvent(Guid CategoryId) : IDomainEvent;
