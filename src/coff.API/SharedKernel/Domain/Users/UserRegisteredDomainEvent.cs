namespace coff.API.SharedKernel.Domain.Users;

public sealed record UserRegisteredDomainEvent(Guid UserId) : IDomainEvent;
