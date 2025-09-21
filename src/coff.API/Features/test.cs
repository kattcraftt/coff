using System.Diagnostics.CodeAnalysis;

namespace coff.API.Features;

public class test
{
    private readonly HttpClient _client;

    public test(HttpClient client)
    {
        _client = client;
    }

    [SuppressMessage("ReSharper", "SuggestVarOrType_BuiltInTypes")]
    public async Task Test()
    {
        var hello = "hello";
        
    }
}
