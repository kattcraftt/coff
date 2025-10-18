namespace coff.API.SharedKernel.Domain.Transactions;

public static class TransactionErrors
{
    public static Error NotFound(Guid transactionId) => Error.NotFound(
        "Transactions.NotFound",
        $"The transaction with the specified transactionId {transactionId} was not found.");

    public static Error Unauthorized(Guid userId) => Error.Failure(
        "Transactions.Unauthorized",
        "You are not authorized to access this transaction.");
}
