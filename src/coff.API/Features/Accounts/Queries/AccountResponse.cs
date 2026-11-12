namespace coff.API.Features.Accounts.Queries;

public sealed class AccountResponse
{
    public Guid Id { get; init; }
    public Guid UserId { get; init; }
    public required string Name { get; init; }
}
