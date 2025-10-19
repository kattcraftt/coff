using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Categories.Queries.GetCategories;

internal sealed class GetCategoriesQueryHandler(IApplicationDbContext context, IUserContext userContext)
    : IQueryHandler<GetCategoriesQuery, List<CategoryResponse>>
{
    public async Task<Result<List<CategoryResponse>>> Handle(GetCategoriesQuery query, CancellationToken cancellationToken)
    {
        List<CategoryResponse> categories = await context.Categories
            .Where(category => category.UserId == userContext.UserId)
            .Select(category => new CategoryResponse
            {
                Id = category.Id,
                Name = category.Name,
                UserId = category.UserId
            }).ToListAsync(cancellationToken);
        
        return categories;
    }
}
