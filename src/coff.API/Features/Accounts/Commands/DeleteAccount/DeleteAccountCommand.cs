using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Accounts.Commands.DeleteAccount;

public sealed record DeleteAccountCommand(Guid AccountId) : ICommand;
