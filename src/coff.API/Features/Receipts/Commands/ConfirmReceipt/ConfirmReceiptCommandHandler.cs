using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Receipts;
using coff.API.SharedKernel.Domain.Transactions;
using coff.API.SharedKernel.Domain.Users;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Receipts.Commands.ConfirmReceipt;

internal sealed class ConfirmReceiptCommandHandler(
    IApplicationDbContext context,
    IUserContext userContext)
    : ICommandHandler<ConfirmReceiptCommand, Guid>
{
    public async Task<Result<Guid>> Handle(ConfirmReceiptCommand command, CancellationToken cancellationToken)
    {
        if (!userContext.IsAuthenticated)
        {
            return Result.Failure<Guid>(UserErrors.Unauthorized());
        }

        Receipt? receipt = await context.Receipts
            .SingleOrDefaultAsync(
                r => r.Id == command.ReceiptId && r.UserId == userContext.UserId,
                cancellationToken);

        if (receipt is null)
        {
            return Result.Failure<Guid>(ReceiptErrors.NotFound(command.ReceiptId));
        }

        if (receipt.Status == ReceiptStatus.Confirmed)
        {
            return Result.Failure<Guid>(ReceiptErrors.AlreadyConfirmed(command.ReceiptId));
        }

        // The account and category must belong to the signed-in user.
        bool accountExists = await context.Accounts
            .AnyAsync(
                a => a.Id == command.AccountId && a.UserId == userContext.UserId,
                cancellationToken);
        if (!accountExists)
        {
            return Result.Failure<Guid>(ReceiptErrors.AccountNotFound(command.AccountId));
        }

        bool categoryExists = await context.Categories
            .AnyAsync(
                c => c.Id == command.CategoryId && c.UserId == userContext.UserId,
                cancellationToken);
        if (!categoryExists)
        {
            return Result.Failure<Guid>(ReceiptErrors.CategoryNotFound(command.CategoryId));
        }

        var transaction = new Transaction
        {
            Id = Guid.NewGuid(),
            // A receipt is money spent: expenses are stored as negative amounts.
            Amount = -Math.Abs(command.Amount),
            Payee = command.Payee,
            Notes = command.Notes,
            Date = command.Date,
            AccountId = command.AccountId,
            CategoryId = command.CategoryId
        };

        transaction.Raise(new TransactionCreatedDomainEvent(transaction.Id));

        // Keep the receipt in sync with what the user actually confirmed.
        receipt.Merchant = command.Payee;
        receipt.Total = Math.Abs(command.Amount);
        receipt.Date = command.Date;
        receipt.Status = ReceiptStatus.Confirmed;
        receipt.TransactionId = transaction.Id;

        receipt.Raise(new ReceiptConfirmedDomainEvent(receipt.Id, transaction.Id));

        context.Transactions.Add(transaction);

        // One SaveChanges => the transaction and the receipt update commit atomically.
        await context.SaveChangesAsync(cancellationToken);

        return transaction.Id;
    }
}
