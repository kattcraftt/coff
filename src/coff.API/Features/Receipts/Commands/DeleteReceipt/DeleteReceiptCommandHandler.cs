using coff.API.Abstractions.Authentication;
using coff.API.Abstractions.Data;
using coff.API.Abstractions.Messaging;
using coff.API.Abstractions.Storage;
using coff.API.SharedKernel;
using coff.API.SharedKernel.Domain.Receipts;
using coff.API.SharedKernel.Domain.Users;
using coff.API.SharedKernel.Infrastructure.Storage;
using Microsoft.EntityFrameworkCore;

namespace coff.API.Features.Receipts.Commands.DeleteReceipt;

/// <summary>
/// Removes the receipt and its photo. A transaction created from the receipt is kept.
/// </summary>
internal sealed class DeleteReceiptCommandHandler(
    IApplicationDbContext context,
    IUserContext userContext,
    IBlobService blobService)
    : ICommandHandler<DeleteReceiptCommand>
{
    public async Task<Result> Handle(DeleteReceiptCommand command, CancellationToken cancellationToken)
    {
        if (!userContext.IsAuthenticated)
        {
            return Result.Failure(UserErrors.Unauthorized());
        }

        Receipt? receipt = await context.Receipts
            .SingleOrDefaultAsync(
                r => r.Id == command.ReceiptId && r.UserId == userContext.UserId,
                cancellationToken);

        if (receipt is null)
        {
            return Result.Failure(ReceiptErrors.NotFound(command.ReceiptId));
        }

        context.Receipts.Remove(receipt);

        await context.SaveChangesAsync(cancellationToken);

        // After the database change, so a failed blob delete never leaves a row pointing at nothing.
        await blobService.DeleteAsync(
            BlobContainers.Receipts,
            userContext.UserId,
            receipt.ImageId,
            cancellationToken);

        return Result.Success();
    }
}
