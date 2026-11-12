using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Users.Commands.ChangePassword;

public sealed class ChangePasswordCommand : ICommand
{
    public required string OldPassword { get; set; }
    
    public required string NewPassword { get; set; }
}
