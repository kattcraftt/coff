using coff.API.Abstractions.Messaging;
using coff.API.Abstractions.Storage;

namespace coff.API.Features.Receipts.Queries.GetReceiptImage;

public sealed record GetReceiptImageQuery(Guid ReceiptId) : IQuery<FileResponse>;
