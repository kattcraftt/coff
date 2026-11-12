namespace coff.API.Features.Users.Queries;

public sealed record UserResponse
{
    public Guid Id { get; init; }
    public required string Email { get; init; }
    public required string FullName { get; init; }

    public string? FirstName { get; init; }
    public string? MiddleName { get; init; }
    public string? LastName { get; init; }
    public string? PhoneNumber { get; init; }
    public string? ProfileImageUrl { get; init; }
}
