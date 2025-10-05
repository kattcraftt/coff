using FluentValidation;

namespace coff.API.Features.Accounts.Commands.CreateAccount;

internal sealed class CreateAccountCommandValidator : AbstractValidator<CreateAccountCommand>
{
    public CreateAccountCommandValidator()
    {
        RuleFor(a => a.Name).NotEmpty();
    }
}
