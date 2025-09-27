using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Users.Queries.GetByEmail;

public sealed record GetUserByEmailQuery(string Email) : IQuery<UserResponse>;
