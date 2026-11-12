using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Receipts.Commands.ConfirmReceipt;

/// <summary>Returns the id of the Transaction created from the receipt.</summary>
public sealed class ConfirmReceiptCommand : ICommand<Guid>
{
    public Guid ReceiptId { get; set; }
    public Guid AccountId { get; set; }
    public Guid CategoryId { get; set; }
    public decimal Amount { get; set; }
    public string Payee { get; set; } = string.Empty;
    public string? Notes { get; set; }
    public DateTime Date { get; set; }
}
