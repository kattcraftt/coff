namespace coff.API.SharedKernel.Domain.Accounts;

public static class AccountErrors
{
    public static Error NotFound(Guid accountId) => Error.NotFound(
        "Accounts.NotFound",
        $"The account with the specified accountId {accountId} was not found.");

    public static Error Unauthorized(Guid userId) => Error.Failure(
        "Accounts.Unauthorized",
        "You are not authorized to access this account.");
}
