using Azure;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using coff.API.Abstractions.Storage;
using Microsoft.Extensions.Azure;
using Microsoft.Extensions.Options;

namespace coff.API.SharedKernel.Infrastructure.Storage;

internal sealed class BlobService(BlobServiceClient blobServiceClient, IOptions<BlobStorageOptions> options) : IBlobService
{
    public async Task<Guid> UploadAsync(
        Stream stream, 
        string contentType, 
        string containerKey, 
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        BlobContainerClient containerClient = await GetContainerAsync(containerKey);

        var fileid = Guid.NewGuid();
        string blobName = $"{userId}/{fileid}";
        
        BlobClient blobClient = containerClient.GetBlobClient(blobName);

        await blobClient.UploadAsync(
            stream,
            new BlobHttpHeaders { ContentType = contentType },
            cancellationToken: cancellationToken);

        return fileid;
    }

    public async Task<FileResponse> DownloadAsync(
        string containerKey, 
        Guid userId,
        Guid fileId, 
        CancellationToken cancellationToken = default)
    {
        BlobContainerClient containerClient = await GetContainerAsync(containerKey);
        
        var fileid = Guid.NewGuid();
        string blobName = $"{userId}/{fileid}";
        
        BlobClient blobClient = containerClient.GetBlobClient(blobName);

        Response<BlobDownloadResult> response =
            await blobClient.DownloadContentAsync(cancellationToken: cancellationToken);
        
        return new FileResponse(response.Value.Content.ToStream(), response.Value.Details.ContentType);
    }

    public async Task DeleteAsync(string containerKey, Guid userId, Guid fileId, CancellationToken cancellationToken = default)
    {
        BlobContainerClient containerClient = await GetContainerAsync(containerKey);
        
        var fileid = Guid.NewGuid();
        string blobName = $"{userId}/{fileid}";
        
        BlobClient blobClient = containerClient.GetBlobClient(blobName);
        
        await blobClient.DeleteIfExistsAsync(cancellationToken: cancellationToken);
    }

    private async Task<BlobContainerClient> GetContainerAsync(string key)
    {
        BlobContainerOptions config = options.Value.Containers[key];

        BlobContainerClient containerClient = 
            blobServiceClient.GetBlobContainerClient(config.Name);

        await containerClient.CreateIfNotExistsAsync(
            publicAccessType: config.Public 
                ? PublicAccessType.Blob 
                : PublicAccessType.None);
        
        return containerClient;
    }
}
