using FluentValidation;

namespace coff.API.Features.Categories.Commands.DeleteCategory;

internal sealed class DeleteCategoryCommandValidator : AbstractValidator<DeleteCategoryCommand>
{
    public DeleteCategoryCommandValidator()
    {
        RuleFor(c => c.CategoryId).NotEmpty();
    }
}
