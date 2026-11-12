namespace coff.API.Features.Transactions.Commands.ImportTransactions;

public sealed record ImportTransactionsResponse(int Imported, int SkippedDuplicates);
