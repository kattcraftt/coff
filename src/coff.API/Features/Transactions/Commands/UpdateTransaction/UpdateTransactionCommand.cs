using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Transactions.Commands.UpdateTransaction;

public sealed class UpdateTransactionCommand : ICommand
{
    public Guid TransactionId { get; set; }
    public Guid AccountId { get; set; }
    public Guid CategoryId { get; set; }
    public decimal Amount { get; set; }
    public required string Payee { get; set; }
    public string? Notes { get; set; }
    public DateTime Date { get; set; }
}
