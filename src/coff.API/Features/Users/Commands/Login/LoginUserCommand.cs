using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Users.Commands.Login;

public sealed record LoginUserCommand(string Email, string Password) : ICommand<string>;
