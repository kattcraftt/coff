using coff.API.SharedKernel.Domain.Receipts;
using coff.API.SharedKernel.Domain.Users;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace coff.API.SharedKernel.Infrastructure.Receipts;

internal sealed class ReceiptConfiguration : IEntityTypeConfiguration<Receipt>
{
    public void Configure(EntityTypeBuilder<Receipt> builder)
    {
        builder.HasKey(r => r.Id);

        builder.HasOne<User>()
            .WithMany()
            .HasForeignKey(r => r.UserId).OnDelete(DeleteBehavior.Cascade);

        builder.Property(r => r.Merchant).HasMaxLength(200);
        builder.Property(r => r.Currency).HasMaxLength(3);
        builder.Property(r => r.Total).HasPrecision(18, 2);
        builder.Property(r => r.Tax).HasPrecision(18, 2);
        builder.Property(r => r.Status).HasConversion<string>().HasMaxLength(20);

        builder.HasIndex(r => new { r.UserId, r.CreatedAtUtc });
    }
}
