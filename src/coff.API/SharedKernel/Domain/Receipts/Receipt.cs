namespace coff.API.SharedKernel.Domain.Receipts;

public sealed class Receipt : Entity
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }

    /// <summary>Blob id of the stored receipt image (see IBlobService).</summary>
    public Guid ImageId { get; set; }

    public string? Merchant { get; set; }
    public DateTime? Date { get; set; }
    public decimal? Total { get; set; }
    public decimal? Tax { get; set; }
    public string? Currency { get; set; }

    public ReceiptStatus Status { get; set; }

    /// <summary>Set once the user confirms the receipt and a Transaction is created from it.</summary>
    public Guid? TransactionId { get; set; }

    public DateTime CreatedAtUtc { get; set; }
}
