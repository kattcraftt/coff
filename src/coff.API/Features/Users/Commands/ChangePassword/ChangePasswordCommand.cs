using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Users.Commands.ChangePassword;

public sealed class ChangePasswordCommand : ICommand
{
    public string OldPassword { get; set; }
    
    public string NewPassword { get; set; }
}
