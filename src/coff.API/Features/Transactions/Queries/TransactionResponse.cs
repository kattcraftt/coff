namespace coff.API.Features.Transactions.Queries;

public sealed class TransactionResponse
{
    public Guid Id { get; init; }
    public decimal Amount { get; init; }
    public string Payee { get; init; }
    public string? Notes { get; init; }
    public DateTime Date { get; init; }
    public Guid AccountId { get; init; }
    public Guid CategoryId { get; init; }
}
