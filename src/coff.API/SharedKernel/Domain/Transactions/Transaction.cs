namespace coff.API.SharedKernel.Domain.Transactions;

public sealed class Transaction : Entity
{
    public Guid Id { get; set; }
    public decimal Amount { get; set; }
    
    public string Payee { get; set; }

    public string? Notes { get; set; }
    
    public DateTime Date { get; set; }
    public Guid AccountId { get; set; }
    public Guid CategoryId { get; set; }
}
