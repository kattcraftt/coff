using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Categories;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Categories.Queries.GetCategoryById;

internal sealed class GetCategoryByIdQueryHandler(IApplicationDbContext context, IUserContext userContext)
    : IQueryHandler<GetCategoryByIdQuery, CategoryResponse>
{
    public async Task<Result<CategoryResponse>> Handle(GetCategoryByIdQuery query, CancellationToken cancellationToken)
    {
        CategoryResponse? category = await context.Categories
            .Where(cat => cat.Id == query.CategoryId && cat.UserId == userContext.UserId)
            .Select(cat => new CategoryResponse
            {
                Id = cat.Id,
                Name = cat.Name,
                UserId = cat.UserId
            })
            .SingleOrDefaultAsync(cancellationToken);

        if (category is null)
        {
            return Result.Failure<CategoryResponse>(CategoryErrors.NotFound(query.CategoryId));
        }
        return category;
    }
}
