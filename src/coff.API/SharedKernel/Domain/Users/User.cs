using Microsoft.AspNetCore.Identity;

namespace coff.API.SharedKernel.Domain.Users;

public sealed class User : IdentityUser<Guid>
{
    public string? FirstName { get; set; }

    public string? MiddleName { get; set; }

    public string? LastName { get; set; }

    public string FullName =>
        string.Join(" ", new[] { FirstName, MiddleName, LastName }
                .Where(n => !string.IsNullOrEmpty(n)));
}
