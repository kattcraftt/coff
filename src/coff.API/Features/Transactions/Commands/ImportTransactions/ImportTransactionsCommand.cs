using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Transactions.Commands.ImportTransactions;

/// <summary>
/// Bulk-creates transactions from a parsed bank statement. Amounts follow the usual
/// convention: negative for expenses, positive for income.
/// </summary>
public sealed class ImportTransactionsCommand : ICommand<ImportTransactionsResponse>
{
    public Guid AccountId { get; set; }

    /// <summary>Statements carry no categories, so every row gets this one (editable later).</summary>
    public Guid CategoryId { get; set; }

    public List<ImportTransactionItem> Items { get; set; } = [];
}

public sealed record ImportTransactionItem(DateTime Date, string Payee, decimal Amount, string? Notes);
