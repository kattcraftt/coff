namespace coff.API.SharedKernel.Domain.Transactions;

public sealed record TransactionDeletedDomainEvent(Guid TransactionId) : IDomainEvent;
