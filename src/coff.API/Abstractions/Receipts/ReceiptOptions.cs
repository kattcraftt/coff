namespace coff.API.Abstractions.Receipts;

public sealed class ReceiptOptions
{
    public const string SectionName = "Receipts";

    /// <summary>AI scans allowed per user per calendar month (UTC). Tune it to your budget.</summary>
    public int MonthlyScanLimit { get; set; } = 30;
}
