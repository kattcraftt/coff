using System.Security.Claims;
using coff.API.Abstractions.Authentication;
using coff.API.SharedKernel.Infrastructure.Authentication;
using Microsoft.AspNetCore.Http;

namespace coff.API.SharedKernel.Infrastructure.Authentication;

internal sealed class UserContext : IUserContext
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public UserContext(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    public Guid UserId =>
        _httpContextAccessor
            .HttpContext?
            .User
            .GetUserId() ??
        throw new ApplicationException("User context is unavailable");

    public string? Email =>
        _httpContextAccessor.HttpContext?.User.GetEmail();

    public bool IsAuthenticated => 
        _httpContextAccessor.HttpContext?.User.Identity?.IsAuthenticated ?? false;
}
