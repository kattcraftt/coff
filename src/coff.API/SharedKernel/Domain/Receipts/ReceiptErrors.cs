namespace coff.API.SharedKernel.Domain.Receipts;

public static class ReceiptErrors
{
    public static Error NotFound(Guid receiptId) => Error.NotFound(
        "Receipts.NotFound",
        $"The receipt with the specified receiptId {receiptId} was not found.");

    public static Error AlreadyConfirmed(Guid receiptId) => Error.Failure(
        "Receipts.AlreadyConfirmed",
        $"The receipt {receiptId} has already been confirmed.");

    public static Error ScanLimitReached(int limit) => Error.Failure(
        "Receipts.ScanLimitReached",
        $"You have used all {limit} scans for this month. Add the expense manually, or try again next month.");

    public static Error UnsupportedImage() => Error.Failure(
        "Receipts.UnsupportedImage",
        "Only JPEG, PNG or WebP images are supported.");

    public static Error NotAReceipt() => Error.Failure(
        "Receipts.NotAReceipt",
        "The image does not appear to be a receipt.");

    public static Error ExtractionFailed() => Error.Failure(
        "Receipts.ExtractionFailed",
        "The receipt could not be read. Try a clearer photo or enter it manually.");

    public static Error AccountNotFound(Guid accountId) => Error.NotFound(
        "Receipts.AccountNotFound",
        $"The account with the specified accountId {accountId} was not found.");

    public static Error CategoryNotFound(Guid categoryId) => Error.NotFound(
        "Receipts.CategoryNotFound",
        $"The category with the specified categoryId {categoryId} was not found.");
}
