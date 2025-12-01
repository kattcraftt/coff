using FluentValidation;

namespace coff.API.Features.Users.Commands.ChangePassword;

public sealed class ChangePasswordCommandValidator : AbstractValidator<ChangePasswordCommand>
{
    public ChangePasswordCommandValidator()
    {
        When(x => !string.IsNullOrWhiteSpace(x.NewPassword), () =>
        {
            RuleFor(x => x.OldPassword)
                .NotEmpty().WithMessage("Old password is required when changing password.");

            RuleFor(x => x.NewPassword)
                .MinimumLength(8).WithMessage("New password must be at least 8 characters.");
        });
    }
}
