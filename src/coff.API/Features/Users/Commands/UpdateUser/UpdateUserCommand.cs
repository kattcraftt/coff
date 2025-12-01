using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Users.Commands.UpdateUser;

public sealed class UpdateUserCommand : ICommand
{
    public string FirstName { get; set; }
    
    public string? MiddleName { get; set; }
    
    public string LastName { get; set; }
    
    public string PhoneNumber { get; set; }
}
