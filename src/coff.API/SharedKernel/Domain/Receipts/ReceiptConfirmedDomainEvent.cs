namespace coff.API.SharedKernel.Domain.Receipts;

public sealed record ReceiptConfirmedDomainEvent(Guid ReceiptId, Guid TransactionId) : IDomainEvent;
