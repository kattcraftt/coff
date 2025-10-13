using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Accounts;
using coff.API.SharedKernel.Domain.Users;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Accounts.Queries.Get;

internal sealed class GetAccountsQueryHandler(IApplicationDbContext context, IUserContext userContext)
    : IQueryHandler<GetAccountsQuery, List<AccountResponse>>
{
    public async Task<Result<List<AccountResponse>>> Handle(GetAccountsQuery query, CancellationToken cancellationToken)
    {
        List<AccountResponse> accounts = await context.Accounts
            .Where(account => account.UserId == userContext.UserId)
            .Select(account => new AccountResponse
            {
                Id = account.Id,
                Name = account.Name,
                UserId = account.UserId
            }).ToListAsync(cancellationToken);
        
        return accounts;
    }
}
