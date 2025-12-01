namespace coff.API.SharedKernel.Domain.Users;

public sealed record UserUpdatedDomainEvent(Guid UserId) : IDomainEvent;
