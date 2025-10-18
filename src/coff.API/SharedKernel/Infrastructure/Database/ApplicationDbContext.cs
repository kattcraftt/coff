using coff.API.Abstractions.Data;
using coff.API.SharedKernel.Domain.Accounts;
using coff.API.SharedKernel.Domain.Categories;
using coff.API.SharedKernel.Domain.Transactions;
using coff.API.SharedKernel.Domain.Users;
using coff.API.SharedKernel.Infrastructure.DomainEvents;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace coff.API.SharedKernel.Infrastructure.Database;

public sealed class ApplicationDbContext(DbContextOptions<ApplicationDbContext> options,
    IDomainEventsDispatcher domainEventsDispatcher)
    : IdentityDbContext<User, IdentityRole<Guid>, Guid>(options), IApplicationDbContext
{
    public DbSet<Account> Accounts { get; set; }
    public DbSet<Category>  Categories { get; set; }
    public DbSet<Transaction> Transactions { get; set; }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        #region Table configurations

        builder.Entity<User>(e => e.ToTable("Users"));
        builder.Entity<IdentityRole<Guid>>(e => e.ToTable("Roles"));
        builder.Entity<IdentityUserRole<Guid>>(e => e.ToTable("UserRoles"));
        builder.Entity<IdentityUserClaim<Guid>>(e => e.ToTable("UserClaims"));
        builder.Entity<IdentityUserLogin<Guid>>(e => e.ToTable("UserLogins"));
        builder.Entity<IdentityUserToken<Guid>>(e => e.ToTable("UserTokens"));
        builder.Entity<IdentityRoleClaim<Guid>>(e => e.ToTable("RoleClaims"));
        
        #endregion
        
        builder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);

        builder.HasDefaultSchema(Schemas.Default);
    }

    public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        // When should you publish domain events?
        //
        // 1. BEFORE calling SaveChangesAsync
        //     - domain events are part of the same transaction
        //     - immediate consistency
        // 2. AFTER calling SaveChangesAsync
        //     - domain events are a separate transaction
        //     - eventual consistency
        //     - handlers can fail

        int result = await base.SaveChangesAsync(cancellationToken);

        await PublishDomainEventsAsync();

        return result;
    }

    private async Task PublishDomainEventsAsync()
    {
        var domainEvents = ChangeTracker
            .Entries<Entity>()
            .Select(entry => entry.Entity)
            .SelectMany(entity =>
            {
                List<IDomainEvent> domainEvents = entity.DomainEvents;

                entity.ClearDomainEvents();

                return domainEvents;
            })
            .ToList();

        await domainEventsDispatcher.DispatchAsync(domainEvents);
    }
}
