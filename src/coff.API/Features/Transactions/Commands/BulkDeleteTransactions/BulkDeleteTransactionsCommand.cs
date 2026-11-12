using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Transactions.Commands.BulkDeleteTransactions;

/// <summary>Deletes several of the user's transactions at once; ids that are not theirs are ignored.</summary>
public sealed class BulkDeleteTransactionsCommand : ICommand<BulkDeleteTransactionsResponse>
{
    public List<Guid> Ids { get; set; } = [];
}
