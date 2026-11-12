using NetArchTest.Rules;

namespace ArchitectureTests;

internal static class Namespaces
{
    public const string Root = "coff.API";
    public const string Features = Root + ".Features";
    public const string Endpoints = Root + ".Endpoints";
    public const string Abstractions = Root + ".Abstractions";
    public const string Messaging = Abstractions + ".Messaging";
    public const string Domain = Root + ".SharedKernel.Domain";
    public const string Infrastructure = Root + ".SharedKernel.Infrastructure";
}

internal static class TestResultExtensions
{
    /// <summary>Failure message that names the offending types.</summary>
    public static string Describe(this TestResult result) =>
        result.FailingTypeNames is null
            ? "Architecture rule violated."
            : "Failing types: " + string.Join(", ", result.FailingTypeNames);
}
