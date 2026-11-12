using System.Globalization;
using System.Net.Http.Json;
using System.Text.Json;
using coff.API.Abstractions.Receipts;
using coff.API.SharedKernel.Domain.Receipts;
using Microsoft.Extensions.Options;

namespace coff.API.SharedKernel.Infrastructure.Receipts;

/// <summary>
/// Reads a receipt photo with Claude. The model is forced to answer through a
/// tool call, so the output is always schema-shaped JSON (never free text),
/// which also limits what any text printed on a receipt can make it do.
/// </summary>
internal sealed class AnthropicReceiptExtractor(
    HttpClient httpClient,
    IOptions<AnthropicOptions> options,
    ILogger<AnthropicReceiptExtractor> logger) : IReceiptExtractor
{
    private const string ToolName = "record_receipt";

    private const string Prompt =
        "Read this receipt and record it with the record_receipt tool. " +
        "Use null for anything you cannot read with confidence; never guess. " +
        "'total' is the final amount paid including tax. " +
        "'date' is the purchase date as yyyy-MM-dd. " +
        "'currency' is an ISO 4217 code (infer it from symbols or country only if clear). " +
        "Set is_receipt to false if the image is not a receipt or invoice.";

    private static readonly object InputSchema = new
    {
        type = "object",
        properties = new
        {
            is_receipt = new { type = "boolean" },
            merchant = new { type = new[] { "string", "null" } },
            date = new { type = new[] { "string", "null" }, description = "yyyy-MM-dd" },
            total = new { type = new[] { "number", "null" } },
            tax = new { type = new[] { "number", "null" } },
            currency = new { type = new[] { "string", "null" }, description = "ISO 4217, e.g. PHP, USD" }
        },
        required = new[] { "is_receipt" }
    };

    public async Task<Result<ReceiptExtraction>> ExtractAsync(
        byte[] image,
        string mediaType,
        CancellationToken cancellationToken)
    {
        AnthropicOptions settings = options.Value;

        if (httpClient.BaseAddress is null)
        {
            logger.LogError("Anthropic:BaseUrl is not configured, receipts cannot be read");
            return Result.Failure<ReceiptExtraction>(ReceiptErrors.ExtractionFailed());
        }

        if (string.IsNullOrWhiteSpace(settings.ApiKey))
        {
            logger.LogError("Anthropic:ApiKey is not configured, receipts cannot be read");
            return Result.Failure<ReceiptExtraction>(ReceiptErrors.ExtractionFailed());
        }

        var body = new
        {
            model = settings.Model,
            max_tokens = 1024,
            tools = new[]
            {
                new
                {
                    name = ToolName,
                    description = "Record the fields read from a receipt.",
                    input_schema = InputSchema
                }
            },
            tool_choice = new { type = "tool", name = ToolName },
            messages = new[]
            {
                new
                {
                    role = "user",
                    content = new object[]
                    {
                        new
                        {
                            type = "image",
                            source = new
                            {
                                type = "base64",
                                media_type = mediaType,
                                data = Convert.ToBase64String(image)
                            }
                        },
                        new { type = "text", text = Prompt }
                    }
                }
            }
        };

        try
        {
            using var request = new HttpRequestMessage(HttpMethod.Post, "v1/messages")
            {
                Content = JsonContent.Create(body)
            };
            request.Headers.Add("x-api-key", settings.ApiKey);
            request.Headers.Add("anthropic-version", "2023-06-01");

            using HttpResponseMessage response = await httpClient.SendAsync(request, cancellationToken);

            if (!response.IsSuccessStatusCode)
            {
                string error = await response.Content.ReadAsStringAsync(cancellationToken);
                logger.LogError(
                    "Receipt extraction failed with {StatusCode}: {Body}",
                    (int)response.StatusCode,
                    error);
                return Result.Failure<ReceiptExtraction>(ReceiptErrors.ExtractionFailed());
            }

            await using Stream stream = await response.Content.ReadAsStreamAsync(cancellationToken);
            using JsonDocument document = await JsonDocument.ParseAsync(stream, cancellationToken: cancellationToken);

            foreach (JsonElement block in document.RootElement.GetProperty("content").EnumerateArray())
            {
                if (block.GetProperty("type").GetString() != "tool_use")
                {
                    continue;
                }

                JsonElement input = block.GetProperty("input");

                if (!input.TryGetProperty("is_receipt", out JsonElement isReceipt)
                    || isReceipt.ValueKind != JsonValueKind.True)
                {
                    return Result.Failure<ReceiptExtraction>(ReceiptErrors.NotAReceipt());
                }

                return new ReceiptExtraction(
                    ReadString(input, "merchant"),
                    ReadDate(input, "date"),
                    ReadDecimal(input, "total"),
                    ReadDecimal(input, "tax"),
                    ReadString(input, "currency")?.ToUpperInvariant());
            }

            logger.LogError("Receipt extraction returned no tool_use block");
            return Result.Failure<ReceiptExtraction>(ReceiptErrors.ExtractionFailed());
        }
        catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException or JsonException or KeyNotFoundException)
        {
            if (cancellationToken.IsCancellationRequested)
            {
                throw;
            }

            logger.LogError(ex, "Receipt extraction threw");
            return Result.Failure<ReceiptExtraction>(ReceiptErrors.ExtractionFailed());
        }
    }

    private static string? ReadString(JsonElement input, string name) =>
        input.TryGetProperty(name, out JsonElement e) && e.ValueKind == JsonValueKind.String
            ? e.GetString()
            : null;

    private static decimal? ReadDecimal(JsonElement input, string name) =>
        input.TryGetProperty(name, out JsonElement e) && e.ValueKind == JsonValueKind.Number
            ? e.GetDecimal()
            : null;

    private static DateTime? ReadDate(JsonElement input, string name)
    {
        string? raw = ReadString(input, name);

        // Receipt dates are calendar dates; store them as UTC midnight so Npgsql accepts them
        // and clients can read back the same y/m/d regardless of timezone.
        return DateTime.TryParseExact(
            raw,
            "yyyy-MM-dd",
            CultureInfo.InvariantCulture,
            DateTimeStyles.AssumeUniversal | DateTimeStyles.AdjustToUniversal,
            out DateTime parsed)
            ? DateTime.SpecifyKind(parsed, DateTimeKind.Utc)
            : null;
    }
}
