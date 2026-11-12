namespace coff.API.SharedKernel.Domain.Receipts;

public sealed record ReceiptScannedDomainEvent(Guid ReceiptId) : IDomainEvent;
