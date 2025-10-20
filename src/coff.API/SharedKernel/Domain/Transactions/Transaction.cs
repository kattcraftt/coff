using coff.API.SharedKernel.Domain.Accounts;
using coff.API.SharedKernel.Domain.Categories;

namespace coff.API.SharedKernel.Domain.Transactions;

public sealed class Transaction : Entity
{
    public Guid Id { get; set; }
    public decimal Amount { get; set; }
    public string Payee { get; set; }
    public string? Notes { get; set; }
    public DateTime Date { get; set; }
    
    public Guid AccountId { get; set; }
    public Account Account { get; set; }
    
    public Guid CategoryId { get; set; }
    public Category Category { get; set; }
}
