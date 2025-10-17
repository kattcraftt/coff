namespace coff.API.SharedKernel.Domain.Categories;

public static class CategoryErrors
{
    public static Error NotFound(Guid categoryId) => Error.NotFound(
        "Accounts.NotFound",
        $"The account with the specified accountId {categoryId} was not found.");

    public static Error Unauthorized(Guid userId) => Error.Failure(
        "Accounts.Unauthorized",
        "You are not authorized to access this account.");
}
