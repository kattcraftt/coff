namespace coff.API.SharedKernel.Domain.Transactions;

public sealed record TransactionUpdatedDomainEvent(Guid TransactionId) : IDomainEvent;
