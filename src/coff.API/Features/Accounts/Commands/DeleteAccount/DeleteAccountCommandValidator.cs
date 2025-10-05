using FluentValidation;

namespace coff.API.Features.Accounts.Commands.DeleteAccount;

internal sealed class DeleteAccountCommandValidator : AbstractValidator<DeleteAccountCommand>
{
    public DeleteAccountCommandValidator()
    {
        RuleFor(a => a.AccountId).NotEmpty();
    }
}
