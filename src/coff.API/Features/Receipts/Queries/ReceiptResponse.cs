namespace coff.API.Features.Receipts.Queries;

public sealed record ReceiptResponse(
    Guid Id,
    string? Merchant,
    DateTime? Date,
    decimal? Total,
    decimal? Tax,
    string? Currency,
    string Status,
    Guid? TransactionId);
