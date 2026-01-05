using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Users.Commands.UploadProfile;

public sealed record UploadProfileImageCommand(
    Stream Stream,
    string ContentType
) : ICommand<Guid>;
