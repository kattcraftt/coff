using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Users.Register;

public sealed record RegisterUserCommand(string Email, string Password, string ConfirmPassword)
    : ICommand<Guid>;
