using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Accounts.Commands.UpdateAccount;

public sealed record UpdateAccountCommand(Guid AccountId, string Name) : ICommand;
