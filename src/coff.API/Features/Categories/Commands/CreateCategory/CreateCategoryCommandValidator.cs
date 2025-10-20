using FluentValidation;

namespace coff.API.Features.Categories.Commands.CreateCategory;

internal sealed class CreateCategoryCommandValidator : AbstractValidator<CreateCategoryCommand>
{
    public CreateCategoryCommandValidator()
    {
        RuleFor(a => a.Name).NotEmpty();
    }
}
