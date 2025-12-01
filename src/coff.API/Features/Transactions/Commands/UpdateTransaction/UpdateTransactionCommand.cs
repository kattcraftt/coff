using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Transactions.Commands.UpdateTransaction;

public sealed class UpdateTransactionCommand : ICommand
{
    public Guid TransactionId { get; set; }
    public decimal Amount { get; set; }
    public string Payee { get; set; }
    public string? Notes { get; set; }
} 
