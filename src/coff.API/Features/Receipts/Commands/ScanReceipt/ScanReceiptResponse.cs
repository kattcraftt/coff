namespace coff.API.Features.Receipts.Commands.ScanReceipt;

public sealed record ScanReceiptResponse(
    Guid Id,
    string? Merchant,
    DateTime? Date,
    decimal? Total,
    decimal? Tax,
    string? Currency,
    string Status);
