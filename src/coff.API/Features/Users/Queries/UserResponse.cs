namespace coff.API.Features.Users.Queries;

public sealed record UserResponse
{
    public Guid Id { get; init; }
    public string Email { get; init; }
    public string FullName { get; init; }
    public string? ProfileImageUrl { get; init; }
}
