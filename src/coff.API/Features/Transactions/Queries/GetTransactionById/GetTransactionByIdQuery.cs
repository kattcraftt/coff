using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Transactions.Queries.GetTransactionById;

public sealed record GetTransactionByIdQuery(Guid TransactionId) : IQuery<TransactionResponse>;
