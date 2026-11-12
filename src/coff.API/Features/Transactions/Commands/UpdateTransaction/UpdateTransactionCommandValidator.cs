using FluentValidation;

namespace coff.API.Features.Transactions.Commands.UpdateTransaction;

internal sealed class UpdateTransactionCommandValidator : AbstractValidator<UpdateTransactionCommand>
{
    public UpdateTransactionCommandValidator()
    {
        RuleFor(t => t.TransactionId).NotEmpty();
        RuleFor(t => t.AccountId).NotEmpty();
        RuleFor(t => t.CategoryId).NotEmpty();
        RuleFor(t => t.Amount).NotEqual(0);
        RuleFor(t => t.Payee).NotEmpty().MaximumLength(200);
        RuleFor(t => t.Notes).MaximumLength(1000);
    }
}
