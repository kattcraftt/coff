using coff.API.SharedKernel.Domain.Users;

namespace coff.API.Abstractions.Authentication;

public interface ITokenProvider
{
    string Create(User user);
}
