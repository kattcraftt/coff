using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Users.Queries.GetById;

public sealed record GetUserByIdQuery(Guid UserId) : IQuery<UserResponse>;
