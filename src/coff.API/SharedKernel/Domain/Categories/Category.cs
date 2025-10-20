using coff.API.SharedKernel.Domain.Transactions;

namespace coff.API.SharedKernel.Domain.Categories;

public sealed class Category : Entity
{
    public Guid Id { get; set; }
    public string Name { get; set; }
    public Guid UserId { get; set; }
    
    public ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
}
