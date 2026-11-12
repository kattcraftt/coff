using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Transactions;
using coff.API.SharedKernel.Domain.Users;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Transactions.Commands.ImportTransactions;

internal sealed class ImportTransactionsCommandHandler(
    IApplicationDbContext context,
    IUserContext userContext)
    : ICommandHandler<ImportTransactionsCommand, ImportTransactionsResponse>
{
    private sealed record Row(DateTime Date, decimal Amount, string Payee, string? Notes);

    public async Task<Result<ImportTransactionsResponse>> Handle(
        ImportTransactionsCommand command,
        CancellationToken cancellationToken)
    {
        if (!userContext.IsAuthenticated)
        {
            return Result.Failure<ImportTransactionsResponse>(UserErrors.Unauthorized());
        }

        // The account and category must belong to the signed-in user.
        bool accountExists = await context.Accounts
            .AnyAsync(
                a => a.Id == command.AccountId && a.UserId == userContext.UserId,
                cancellationToken);
        if (!accountExists)
        {
            return Result.Failure<ImportTransactionsResponse>(
                TransactionErrors.AccountNotFound(command.AccountId));
        }

        bool categoryExists = await context.Categories
            .AnyAsync(
                c => c.Id == command.CategoryId && c.UserId == userContext.UserId,
                cancellationToken);
        if (!categoryExists)
        {
            return Result.Failure<ImportTransactionsResponse>(
                TransactionErrors.CategoryNotFound(command.CategoryId));
        }

        // Statement dates are calendar dates: keep them as UTC midnight, like the rest of the app.
        var rows = command.Items
            .Select(i => new Row(
                DateTime.SpecifyKind(i.Date.Date, DateTimeKind.Utc),
                Math.Round(i.Amount, 2),
                i.Payee.Trim(),
                string.IsNullOrWhiteSpace(i.Notes) ? null : i.Notes.Trim()))
            .ToList();

        DateTime from = rows.Min(r => r.Date);
        DateTime until = rows.Max(r => r.Date).AddDays(1);

        // Importing the same statement twice must not double everything: skip rows that already
        // exist in this account with the same day, amount and payee.
        List<Row> existing = await context.Transactions
            .AsNoTracking()
            .Where(t => t.AccountId == command.AccountId && t.Date >= from && t.Date < until)
            .Select(t => new Row(t.Date, t.Amount, t.Payee, null))
            .ToListAsync(cancellationToken);

        HashSet<(DateTime, decimal, string)> known = existing
            .Select(e => (e.Date.Date, e.Amount, Normalize(e.Payee)))
            .ToHashSet();

        int skipped = 0;
        foreach (Row row in rows)
        {
            if (known.Contains((row.Date, row.Amount, Normalize(row.Payee))))
            {
                skipped++;
                continue;
            }

            var transaction = new Transaction
            {
                Id = Guid.NewGuid(),
                Amount = row.Amount,
                Payee = row.Payee,
                Notes = row.Notes,
                Date = row.Date,
                AccountId = command.AccountId,
                CategoryId = command.CategoryId
            };

            transaction.Raise(new TransactionCreatedDomainEvent(transaction.Id));

            context.Transactions.Add(transaction);
        }

        // One SaveChanges: the whole import succeeds or fails together.
        await context.SaveChangesAsync(cancellationToken);

        return new ImportTransactionsResponse(rows.Count - skipped, skipped);
    }

    private static string Normalize(string payee) => payee.Trim().ToUpperInvariant();
}
