using coff.API.SharedKernel;

namespace coff.API.Abstractions.Receipts;

public sealed record ReceiptExtraction(
    string? Merchant,
    DateTime? Date,
    decimal? Total,
    decimal? Tax,
    string? Currency);

public interface IReceiptExtractor
{
    /// <param name="mediaType">image/jpeg, image/png or image/webp</param>
    Task<Result<ReceiptExtraction>> ExtractAsync(
        byte[] image,
        string mediaType,
        CancellationToken cancellationToken);
}
