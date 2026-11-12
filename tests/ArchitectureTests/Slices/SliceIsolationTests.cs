using NetArchTest.Rules;
using Shouldly;

namespace ArchitectureTests.Slices;

/// <summary>
/// Vertical slice rule: a feature (Accounts, Receipts, ...) never references
/// another feature. Shared things live in SharedKernel or Abstractions.
/// New feature folders are picked up automatically.
/// </summary>
public class SliceIsolationTests : BaseTest
{
    public static TheoryData<string> SliceNames
    {
        get
        {
            var data = new TheoryData<string>();
            foreach (string name in DiscoverSlices())
            {
                data.Add(name);
            }

            return data;
        }
    }

    [Theory]
    [MemberData(nameof(SliceNames))]
    public void Slice_Should_NotDependOnOtherSlices(string slice)
    {
        string[] otherSlices = DiscoverSlices()
            .Where(s => s != slice)
            .Select(s => $"{Namespaces.Features}.{s}.")
            .ToArray();

        TestResult result = Types.InAssembly(PresentationAssembly)
            .That().ResideInNamespace($"{Namespaces.Features}.{slice}")
            .ShouldNot().HaveDependencyOnAny(otherSlices)
            .GetResult();

        result.IsSuccessful.ShouldBeTrue(result.Describe());
    }

    [Fact]
    public void Features_Should_ContainSlices()
    {
        DiscoverSlices().ShouldNotBeEmpty();
    }

    private static IEnumerable<string> DiscoverSlices() =>
        PresentationAssembly.GetTypes()
            .Select(t => t.Namespace)
            .Where(ns => ns is not null && ns.StartsWith(Namespaces.Features + ".", StringComparison.Ordinal))
            .Select(ns => ns!.Split('.')[3]) // coff.API.Features.<Slice>...
            .Distinct()
            .Order();
}
