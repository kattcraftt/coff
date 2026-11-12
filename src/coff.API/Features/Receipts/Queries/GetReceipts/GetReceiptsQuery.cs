using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Receipts.Queries.GetReceipts;

public sealed record GetReceiptsQuery : IQuery<List<ReceiptResponse>>;
