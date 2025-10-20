using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Categories;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Categories.Commands.DeleteCategory;

internal sealed class DeleteCategoryCommandHandler(
    IApplicationDbContext context,
    IUserContext userContext)
    : ICommandHandler<DeleteCategoryCommand>
{
    public async Task<Result> Handle(DeleteCategoryCommand command, CancellationToken cancellationToken)
    {
        Category? category = await context.Categories
            .SingleOrDefaultAsync(a => a.Id == command.CategoryId && a.UserId == userContext.UserId, cancellationToken);

        if (category is null)
        {
            return Result.Failure(CategoryErrors.NotFound(command.CategoryId));
        }

        context.Categories.Remove(category);
        
        category.Raise(new CategoryDeletedDomainEvent(category.Id));

        await context.SaveChangesAsync(cancellationToken);
        
        return Result.Success();
    }
}
