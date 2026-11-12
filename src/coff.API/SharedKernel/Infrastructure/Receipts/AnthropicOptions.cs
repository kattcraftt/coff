namespace coff.API.SharedKernel.Infrastructure.Receipts;

public sealed class AnthropicOptions
{
    public const string SectionName = "Anthropic";

    /// <summary>Set via user-secrets / environment variable, never commit it.</summary>
    public string ApiKey { get; set; } = string.Empty;

    /// <summary>Set in appsettings.json (Anthropic:BaseUrl); kept out of code on purpose.</summary>
    public string BaseUrl { get; set; } = string.Empty;

    public string Model { get; set; } = "claude-sonnet-5-5";
}
