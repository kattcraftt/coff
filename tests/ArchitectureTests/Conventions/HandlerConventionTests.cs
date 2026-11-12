using NetArchTest.Rules;
using Shouldly;

namespace ArchitectureTests.Conventions;

public class HandlerConventionTests : BaseTest
{
    [Fact]
    public void CommandHandlers_WithResponse_Should_BeInternalSealedAndNamedCommandHandler() =>
        AssertConvention("ICommandHandler`2", "CommandHandler");

    [Fact]
    public void CommandHandlers_WithoutResponse_Should_BeInternalSealedAndNamedCommandHandler() =>
        AssertConvention("ICommandHandler`1", "CommandHandler");

    [Fact]
    public void QueryHandlers_Should_BeInternalSealedAndNamedQueryHandler() =>
        AssertConvention("IQueryHandler`2", "QueryHandler");

    private static void AssertConvention(string handlerInterface, string suffix)
    {
        // Looked up by name through reflection so this works even if the interface is internal.
        Type handlerType = PresentationAssembly.GetType(
            $"{Namespaces.Messaging}.{handlerInterface}",
            throwOnError: true)!;

        TestResult result = Types.InAssembly(PresentationAssembly)
            .That().ResideInNamespace(Namespaces.Features)
            .And().ImplementInterface(handlerType)
            .Should().NotBePublic()
            .And().BeSealed()
            .And().HaveNameEndingWith(suffix)
            .GetResult();

        result.IsSuccessful.ShouldBeTrue(result.Describe());
    }
}
