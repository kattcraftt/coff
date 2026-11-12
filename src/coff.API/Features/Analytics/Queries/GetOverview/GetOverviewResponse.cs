namespace coff.API.Features.Analytics.Queries.GetOverview;

/// <summary>
/// Sign convention: Income is positive, Expenses is negative (as stored on
/// transactions), Remaining = Income + Expenses. The Previous* values cover the
/// period of the same length immediately before From.
/// </summary>
public sealed record GetOverviewResponse(
    DateOnly From,
    DateOnly To,
    decimal Income,
    decimal Expenses,
    decimal Remaining,
    decimal PreviousIncome,
    decimal PreviousExpenses,
    decimal PreviousRemaining,
    int PendingReceipts,
    List<DailyTotal> Daily,
    List<CategoryTotal> Categories,
    List<PayeeTotal> TopPayees);

public sealed record DailyTotal(DateOnly Date, decimal Income, decimal Expenses);

/// <summary>Expense totals per category, as positive amounts.</summary>
public sealed record CategoryTotal(string Name, decimal Amount);

/// <summary>Where the most money went, by payee, as positive amounts.</summary>
public sealed record PayeeTotal(string Payee, decimal Amount);
