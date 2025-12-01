using FluentValidation;

namespace coff.API.Features.Users.Commands.UpdateUser;

public sealed class UpdateUserCommandValidator : AbstractValidator<UpdateUserCommand>
{
    public UpdateUserCommandValidator()
    {
        RuleFor(u => u.FirstName).NotEmpty();
        RuleFor(u => u.LastName).NotEmpty();
        RuleFor(u => u.PhoneNumber).NotEmpty();

        When(
            u => !string.IsNullOrWhiteSpace(u.NewPassword),
            () =>
            {
                RuleFor(u => u.OldPassword).NotEmpty().WithMessage("Old password is required.");
                RuleFor(u => u.NewPassword).MinimumLength(8)
                    .WithMessage("New password must be at least 8 characters.");
            });
    }
}
