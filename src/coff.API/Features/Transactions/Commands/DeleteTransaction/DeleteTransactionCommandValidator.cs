using FluentValidation;

namespace coff.API.Features.Transactions.Commands.DeleteTransaction;

internal sealed class DeleteTransactionCommandValidator : AbstractValidator<DeleteTransactionCommand>
{
    public DeleteTransactionCommandValidator()
    {
        RuleFor(c => c.TransactionId).NotEmpty();
    }
}
