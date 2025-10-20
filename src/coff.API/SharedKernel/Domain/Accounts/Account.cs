using coff.API.SharedKernel.Domain.Transactions;

namespace coff.API.SharedKernel.Domain.Accounts;

public sealed class Account : Entity
{
    public Guid Id { get; set; }
    public string? PlaidAccountId { get; set; }
    public string Name { get; set; }
    public Guid UserId { get; set; }

    public ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
}
