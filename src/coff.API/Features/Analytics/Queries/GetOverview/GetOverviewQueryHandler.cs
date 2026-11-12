using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Receipts;
using coff.API.SharedKernel.Domain.Transactions;
using coff.API.SharedKernel.Domain.Users;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Analytics.Queries.GetOverview;

internal sealed class GetOverviewQueryHandler(
    IApplicationDbContext context,
    IUserContext userContext)
    : IQueryHandler<GetOverviewQuery, GetOverviewResponse>
{
    private const int MaxCategories = 5;
    private const int MaxTopPayees = 5;
    private const int MaxRangeDays = 366;

    private sealed record Row(decimal Amount, DateTime Date, string CategoryName, string Payee);

    public async Task<Result<GetOverviewResponse>> Handle(
        GetOverviewQuery query,
        CancellationToken cancellationToken)
    {
        if (!userContext.IsAuthenticated)
        {
            return Result.Failure<GetOverviewResponse>(UserErrors.Unauthorized());
        }

        if (query.To < query.From || query.To.DayNumber - query.From.DayNumber > MaxRangeDays)
        {
            return Result.Failure<GetOverviewResponse>(Error.Problem(
                "Analytics.InvalidRange",
                "'to' must be on or after 'from', and the range at most one year."));
        }

        var start = query.From.ToDateTime(TimeOnly.MinValue, DateTimeKind.Utc);
        var endExclusive = query.To.AddDays(1).ToDateTime(TimeOnly.MinValue, DateTimeKind.Utc);
        int days = (int)(endExclusive - start).TotalDays;
        DateTime previousStart = start.AddDays(-days);

        // Transactions belong to a user through their Account.
        IQueryable<Transaction> transactions = context.Transactions
            .AsNoTracking()
            .Where(t => t.Account.UserId == userContext.UserId);

        if (query.AccountId is Guid accountId)
        {
            transactions = transactions.Where(t => t.AccountId == accountId);
        }

        // Both periods in one round trip; aggregated in memory. Fine for an MVP,
        // move to GROUP BY in SQL when a single user has many thousands of rows.
        List<Row> rows = await transactions
            .Where(t => t.Date >= previousStart && t.Date < endExclusive)
            .Select(t => new Row(t.Amount, t.Date, t.Category.Name, t.Payee))
            .ToListAsync(cancellationToken);

        var current = rows.Where(r => r.Date >= start).ToList();
        var previous = rows.Where(r => r.Date < start).ToList();

        decimal income = SumPositive(current);
        decimal expenses = SumNegative(current);
        decimal previousIncome = SumPositive(previous);
        decimal previousExpenses = SumNegative(previous);

        var daily = new List<DailyTotal>(days);
        for (int i = 0; i < days; i++)
        {
            DateTime day = start.AddDays(i);
            var dayRows = current.Where(r => r.Date.Date == day.Date).ToList();
            daily.Add(new DailyTotal(DateOnly.FromDateTime(day), SumPositive(dayRows), SumNegative(dayRows)));
        }

        var byCategory = current
            .Where(r => r.Amount < 0)
            .GroupBy(r => r.CategoryName)
            .Select(g => new CategoryTotal(g.Key, -g.Sum(r => r.Amount)))
            .OrderByDescending(c => c.Amount)
            .ToList();

        var categories = byCategory.Take(MaxCategories).ToList();
        decimal other = byCategory.Skip(MaxCategories).Sum(c => c.Amount);
        if (other > 0)
        {
            categories.Add(new CategoryTotal("Other", other));
        }

        var topPayees = current
            .Where(r => r.Amount < 0)
            .GroupBy(r => r.Payee.Trim().ToUpperInvariant())
            .Select(g => new PayeeTotal(g.First().Payee.Trim(), -g.Sum(r => r.Amount)))
            .OrderByDescending(p => p.Amount)
            .Take(MaxTopPayees)
            .ToList();

        int pendingReceipts = await context.Receipts
            .CountAsync(
                r => r.UserId == userContext.UserId && r.Status == ReceiptStatus.Pending,
                cancellationToken);

        return new GetOverviewResponse(
            query.From,
            query.To,
            income,
            expenses,
            income + expenses,
            previousIncome,
            previousExpenses,
            previousIncome + previousExpenses,
            pendingReceipts,
            daily,
            categories,
            topPayees);
    }

    private static decimal SumPositive(IEnumerable<Row> rows) =>
        rows.Where(r => r.Amount > 0).Sum(r => r.Amount);

    private static decimal SumNegative(IEnumerable<Row> rows) =>
        rows.Where(r => r.Amount < 0).Sum(r => r.Amount);
}
