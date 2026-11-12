using FluentValidation;

namespace coff.API.Features.Receipts.Commands.DeleteReceipt;

internal sealed class DeleteReceiptCommandValidator : AbstractValidator<DeleteReceiptCommand>
{
    public DeleteReceiptCommandValidator()
    {
        RuleFor(c => c.ReceiptId).NotEmpty();
    }
}
