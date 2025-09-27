using coff.API.Abstractions.Messaging;
using coff.API.Features.Users.Queries;

namespace coff.API.Features.Users.GetById;

public sealed record GetUserByIdQuery(Guid UserId) : IQuery<UserResponse>;
