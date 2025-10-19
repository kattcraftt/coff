using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Categories.Queries.GetCategories;

public sealed record GetCategoriesQuery() : IQuery<List<CategoryResponse>>;
