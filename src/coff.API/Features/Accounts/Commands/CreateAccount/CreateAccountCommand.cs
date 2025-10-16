using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Accounts.Commands.CreateAccount;

public sealed record CreateAccountCommand(string Name) : ICommand<Guid>;
