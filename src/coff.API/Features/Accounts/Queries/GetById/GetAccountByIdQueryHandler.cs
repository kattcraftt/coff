using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Accounts;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Accounts.Queries.GetById;

internal sealed class GetAccountByIdQueryHandler(IApplicationDbContext context, IUserContext userContext)
    : IQueryHandler<GetAccountByIdQuery, AccountResponse>
{
    public async Task<Result<AccountResponse>> Handle(GetAccountByIdQuery query, CancellationToken cancellationToken)
    {
        AccountResponse? account = await context.Accounts
            .Where(acc => acc.Id == query.AccountId && acc.UserId == userContext.UserId)
            .Select(acc => new AccountResponse
            {
                Id = acc.Id,
                Name = acc.Name,
                UserId = acc.UserId
            })
            .SingleOrDefaultAsync(cancellationToken);

        if (account is null)
        {
            return Result.Failure<AccountResponse>(AccountErrors.NotFound(query.AccountId));
        }
        return account;
    }
}
