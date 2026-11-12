using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Receipts.Commands.ScanReceipt;

public sealed class ScanReceiptCommand : ICommand<ScanReceiptResponse>
{
    public required Stream Content { get; set; }
    public long Length { get; set; }
}
