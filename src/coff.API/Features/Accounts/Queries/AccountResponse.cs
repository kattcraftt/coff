namespace coff.API.Features.Accounts.Queries;

public sealed class AccountResponse
{
    public Guid Id { get; init; }
    
    public Guid UserId { get; init; }
    public string Name { get; init; }
}
