namespace coff.API.SharedKernel.Infrastructure.Storage;

public sealed class BlobContainerOptions
{
    public string Name { get; set; } = default!;
    public bool Public { get; set; }
}
