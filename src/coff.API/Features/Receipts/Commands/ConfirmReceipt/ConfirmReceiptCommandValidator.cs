using FluentValidation;

namespace coff.API.Features.Receipts.Commands.ConfirmReceipt;

internal sealed class ConfirmReceiptCommandValidator : AbstractValidator<ConfirmReceiptCommand>
{
    public ConfirmReceiptCommandValidator()
    {
        RuleFor(c => c.ReceiptId).NotEmpty();
        RuleFor(c => c.AccountId).NotEmpty();
        RuleFor(c => c.CategoryId).NotEmpty();
        RuleFor(c => c.Amount).NotEqual(0);
        RuleFor(c => c.Payee).NotEmpty().MaximumLength(200);
        RuleFor(c => c.Notes).MaximumLength(1000);
    }
}
