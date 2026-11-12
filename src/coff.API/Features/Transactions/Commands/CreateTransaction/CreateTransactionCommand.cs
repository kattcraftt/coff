using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Transactions.Commands.CreateTransaction;

public sealed class CreateTransactionCommand : ICommand<Guid>
{
    public Guid AccountId { get; set; }
    public Guid CategoryId { get; set; }

    /// <summary>Negative for expenses, positive for income.</summary>
    public decimal Amount { get; set; }

    public string Payee { get; set; } = string.Empty;
    public string? Notes { get; set; }
    public DateTime Date { get; set; }
}
