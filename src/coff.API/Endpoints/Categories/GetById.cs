using coff.API.Abstractions.Messaging;
using coff.API.Endpoints.Shared;
using coff.API.SharedKernel;
using coff.API.Extensions;
using coff.API.Features.Categories.Queries;
using coff.API.Features.Categories.Queries.GetCategoryById;
using coff.API.SharedKernel.Infrastructure;

namespace coff.API.Endpoints.Categories;

internal sealed class GetById : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("categories/{id:guid}", async (
            Guid id,
            IQueryHandler<GetCategoryByIdQuery, CategoryResponse> handler,
            CancellationToken cancellationToken) =>
        {
            var command = new GetCategoryByIdQuery(id);

            Result<CategoryResponse> result = await handler.Handle(command, cancellationToken);

            return result.Match(Results.Ok, CustomResults.Problem);
        })
        .WithTags(Tags.Categories)
        .RequireAuthorization();
    }
}
