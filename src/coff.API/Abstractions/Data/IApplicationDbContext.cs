using coff.API.SharedKernel.Domain.Accounts;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Abstractions.Data;

public interface IApplicationDbContext
{
    DbSet<Account>  Accounts { get; set; }
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
