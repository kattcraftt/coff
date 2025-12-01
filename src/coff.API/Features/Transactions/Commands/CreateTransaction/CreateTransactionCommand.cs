using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Transactions.Commands.CreateTransaction;

public sealed class CreateTransactionCommand : ICommand<Guid>
{
    public decimal Amount { get; set; }
    public string Payee { get; set; }
    public string? Notes { get; set; }
    public DateTime Date { get; set; }
} 
