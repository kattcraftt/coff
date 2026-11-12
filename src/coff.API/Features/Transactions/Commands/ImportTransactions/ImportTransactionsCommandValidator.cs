using FluentValidation;

namespace coff.API.Features.Transactions.Commands.ImportTransactions;

internal sealed class ImportTransactionsCommandValidator : AbstractValidator<ImportTransactionsCommand>
{
    public const int MaxItems = 1000;

    // The amount column is decimal(18,2).
    private const decimal MaxAmount = 1_000_000_000_000m;

    public ImportTransactionsCommandValidator()
    {
        RuleFor(c => c.AccountId).NotEmpty();
        RuleFor(c => c.CategoryId).NotEmpty();

        RuleFor(c => c.Items)
            .NotEmpty()
            .Must(items => items.Count <= MaxItems)
            .WithMessage($"At most {MaxItems} transactions can be imported at once.");

        RuleForEach(c => c.Items).ChildRules(item =>
        {
            item.RuleFor(i => i.Payee).NotEmpty().MaximumLength(200);
            item.RuleFor(i => i.Notes).MaximumLength(1000);
            item.RuleFor(i => i.Amount)
                .NotEqual(0)
                .Must(amount => Math.Abs(amount) < MaxAmount)
                .WithMessage("An amount is too large.");
        });
    }
}
