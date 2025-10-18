namespace coff.API.SharedKernel.Domain.Transactions;

public sealed record TransactionCreatedDomainEvent(Guid TransactionId) : IDomainEvent;
