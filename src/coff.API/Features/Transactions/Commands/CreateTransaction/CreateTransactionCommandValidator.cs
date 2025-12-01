using FluentValidation;

namespace coff.API.Features.Transactions.Commands.CreateTransaction;

internal sealed class CreateTransactionCommandValidator : AbstractValidator<CreateTransactionCommand>
{
    public CreateTransactionCommandValidator()
    {
        RuleFor(t => t.Amount).NotEmpty();
        RuleFor(t => t.Payee).NotEmpty();
    }
}
