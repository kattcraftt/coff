using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Receipts.Commands.DeleteReceipt;

public sealed record DeleteReceiptCommand(Guid ReceiptId) : ICommand;
