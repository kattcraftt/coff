using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Categories;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Categories.Commands.UpdateCategory;

internal sealed class UpdateCategoryCommandHandler(
    IApplicationDbContext context,
    IUserContext userContext) 
    : ICommandHandler<UpdateCategoryCommand>
{
    public async Task<Result> Handle(UpdateCategoryCommand command, CancellationToken cancellationToken)
    {
        Category? category = await context.Categories
            .SingleOrDefaultAsync(a => a.Id == command.CategoryId && a.UserId == userContext.UserId, cancellationToken);

        if (category is null)
        {
            return Result.Failure(CategoryErrors.NotFound(command.CategoryId));
        }
        
        category.Name = command.Name;
        
        category.Raise(new CategoryUpdatedDomainEvent(category.Id));
        
        await context.SaveChangesAsync(cancellationToken);
        
        return Result.Success();
    }
}
