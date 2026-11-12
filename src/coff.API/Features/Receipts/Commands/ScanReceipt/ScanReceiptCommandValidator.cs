using FluentValidation;

namespace coff.API.Features.Receipts.Commands.ScanReceipt;

internal sealed class ScanReceiptCommandValidator : AbstractValidator<ScanReceiptCommand>
{
    // The Anthropic API rejects images over 5 MB, so we cap uploads there.
    private const long MaxBytes = 5 * 1024 * 1024;

    public ScanReceiptCommandValidator()
    {
        RuleFor(c => c.Length)
            .GreaterThan(0).WithMessage("The image is empty.")
            .LessThanOrEqualTo(MaxBytes).WithMessage("The image must be 5 MB or smaller.");
    }
}
