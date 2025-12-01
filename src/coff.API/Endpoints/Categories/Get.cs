using coff.API.Abstractions.Messaging;
using coff.API.Endpoints.Shared;
using coff.API.SharedKernel;
using coff.API.Extensions;
using coff.API.Features.Categories.Queries;
using coff.API.Features.Categories.Queries.GetCategories;
using coff.API.SharedKernel.Infrastructure;

namespace coff.API.Endpoints.Categories;

internal sealed class Get : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("categories", async (
            IQueryHandler<GetCategoriesQuery, List<CategoryResponse>> handler,
            CancellationToken cancellationToken) =>
        {
            var query = new GetCategoriesQuery();

            Result<List<CategoryResponse>> result = await handler.Handle(query, cancellationToken);

            return result.Match(Results.Ok, CustomResults.Problem);
        })
        .WithTags(Tags.Categories)
        .RequireAuthorization();
    }
}
