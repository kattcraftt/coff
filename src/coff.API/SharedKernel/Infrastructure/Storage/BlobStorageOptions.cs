namespace coff.API.SharedKernel.Infrastructure.Storage;

public sealed class BlobStorageOptions
{
    public string? AccountUrl { get; set; }
    public bool UseConnectionString { get; set; }
    public string ConnectionString { get; set; }

    public Dictionary<string, BlobContainerOptions> Containers { get; set; } = [];
}

