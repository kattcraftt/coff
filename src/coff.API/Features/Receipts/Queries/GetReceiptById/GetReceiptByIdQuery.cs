using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Receipts.Queries.GetReceiptById;

public sealed record GetReceiptByIdQuery(Guid ReceiptId) : IQuery<ReceiptResponse>;
