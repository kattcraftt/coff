using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Transactions.Queries.GetTransactions;

public sealed record GetTransactionsQuery() : IQuery<List<TransactionResponse>>;
