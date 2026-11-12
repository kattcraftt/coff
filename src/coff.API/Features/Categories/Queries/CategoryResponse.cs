namespace coff.API.Features.Categories.Queries;

public sealed class CategoryResponse
{
    public Guid Id { get; init; }
    public Guid UserId { get; init; }
    public required string Name { get; init; }
}
