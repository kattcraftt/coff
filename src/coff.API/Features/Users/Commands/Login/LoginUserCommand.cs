using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Users.Login;

public sealed record LoginUserCommand(string Email, string Password) : ICommand<string>;
