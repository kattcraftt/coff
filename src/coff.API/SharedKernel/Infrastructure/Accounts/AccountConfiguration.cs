using coff.API.SharedKernel.Domain.Accounts;
using coff.API.SharedKernel.Domain.Users;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace coff.API.SharedKernel.Infrastructure.Accounts;

internal sealed class AccountConfiguration : IEntityTypeConfiguration<Account>
{
    public void Configure(EntityTypeBuilder<Account> builder)
    {
        builder.HasKey(a => a.Id);

        builder.Property(a => a.Name)
            .HasMaxLength(50);

        builder.HasOne<User>()
            .WithMany()
            .HasForeignKey(a => a.UserId).OnDelete(DeleteBehavior.Cascade);
    }
}
