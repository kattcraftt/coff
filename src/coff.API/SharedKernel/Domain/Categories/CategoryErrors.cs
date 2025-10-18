namespace coff.API.SharedKernel.Domain.Categories;

public static class CategoryErrors
{
    public static Error NotFound(Guid categoryId) => Error.NotFound(
        "Categories.NotFound",
        $"The category with the specified categoryId {categoryId} was not found.");

    public static Error Unauthorized(Guid userId) => Error.Failure(
        "Categories.Unauthorized",
        "You are not authorized to access this category.");
}
