using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Accounts;
using coff.API.SharedKernel.Domain.Categories;
using coff.API.SharedKernel.Domain.Users;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Categories.Commands.CreateCategory;

internal sealed class CreateCategoryCommandHandler(
    IApplicationDbContext context,
    IUserContext userContext) 
    : ICommandHandler<CreateCategoryCommand, Guid>
{
    public async Task<Result<Guid>> Handle(CreateCategoryCommand command, CancellationToken cancellationToken)
    {
        if (!userContext.IsAuthenticated)
        {
            return Result.Failure<Guid>(UserErrors.Unauthorized());
        }

        var category = new Category
        {
            Name = command.Name,
            UserId = userContext.UserId
        };
        
        category.Raise(new CategoryCreatedDomainEvent(category.Id));

        context.Categories.Add(category);
        
        await context.SaveChangesAsync(cancellationToken);
        
        return category.Id;
    }
}
