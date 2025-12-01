using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Transactions.Commands.DeleteTransaction;

public sealed record DeleteTransactionCommand(Guid TransactionId) : ICommand;
