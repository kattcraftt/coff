using coff.API.SharedKernel.Domain.Accounts;
using coff.API.SharedKernel.Domain.Categories;
using coff.API.SharedKernel.Domain.Transactions;
using coff.API.SharedKernel.Domain.Receipts;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Abstractions.Data;

public interface IApplicationDbContext
{
    DbSet<Account>  Accounts { get; set; }
    DbSet<Category> Categories { get; set; }
    DbSet<Receipt>  Receipts { get; set; }
    DbSet<Transaction> Transactions { get; set; }
    
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
