using coff.API.SharedKernel.Domain.Accounts;
using coff.API.SharedKernel.Domain.Categories;
using coff.API.SharedKernel.Domain.Transactions;
using coff.API.SharedKernel.Domain.Users;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace coff.API.SharedKernel.Infrastructure.Transactions;

internal sealed class TransactionConfiguration : IEntityTypeConfiguration<Transaction>
{
    public void Configure(EntityTypeBuilder<Transaction> builder)
    {
        builder.HasKey(t => t.Id);
        
        builder.Property(t => t.Amount)
            .HasColumnType("decimal(18,2)");
        
        builder.HasOne<Account>()
            .WithMany()
            .HasForeignKey(a => a.AccountId).OnDelete(DeleteBehavior.Cascade);

        builder.HasOne<Category>()
            .WithMany()
            .HasForeignKey(c => c.CategoryId).OnDelete(DeleteBehavior.SetNull);
    }
}
