using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Accounts.Commands.UpdateAccount;

public sealed record UpdateAccontCommand(Guid AccountId, string Name) : ICommand;
