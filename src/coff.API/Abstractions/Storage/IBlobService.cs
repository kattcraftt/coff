namespace coff.API.Abstractions.Storage;

public interface IBlobService
{
    Task<Guid> UploadAsync(Stream stream, string contentType, string containerKey, Guid userId, CancellationToken cancellationToken = default);

    Task<FileResponse> DownloadAsync(string containerKey, Guid userId, Guid fileId, CancellationToken cancellationToken = default);
    
    Task DeleteAsync(string containerKey, Guid userId, Guid fileId, CancellationToken cancellationToken = default);
    
    Uri? GetPublicUrl(string containerKey, Guid userId, Guid fileId);
}
