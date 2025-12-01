using FluentValidation;

namespace coff.API.Features.Categories.Commands.DeleteCategory;

internal sealed class DeleteTransactionCommandValidator : AbstractValidator<DeleteCategoryCommand>
{
    public DeleteTransactionCommandValidator()
    {
        RuleFor(c => c.CategoryId).NotEmpty();
    }
}
