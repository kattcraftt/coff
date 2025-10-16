namespace coff.API.Abstractions.Authentication;

public interface IUserContext
{
    Guid UserId { get; }

    string? Email { get; }
    bool IsAuthenticated { get; }
}
