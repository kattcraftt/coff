using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Users.Queries.Get;

public sealed record GetUsersQuery() : IQuery<UserResponse>;
