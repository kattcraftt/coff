using FluentValidation;

namespace coff.API.Features.Transactions.Commands.BulkDeleteTransactions;

internal sealed class BulkDeleteTransactionsCommandValidator : AbstractValidator<BulkDeleteTransactionsCommand>
{
    public const int MaxIds = 500;

    public BulkDeleteTransactionsCommandValidator()
    {
        RuleFor(c => c.Ids)
            .NotEmpty()
            .Must(ids => ids.Count <= MaxIds)
            .WithMessage($"At most {MaxIds} transactions can be deleted at once.");
    }
}
