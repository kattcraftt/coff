using NetArchTest.Rules;
using Shouldly;

namespace ArchitectureTests.Layers;

/// <summary>
/// coff.API is one project, so "layers" are namespaces, not assemblies.
/// Dependencies point inwards: Endpoints -> Features -> Abstractions -> Domain.
/// </summary>
public class NamespaceLayerTests : BaseTest
{
    [Fact]
    public void Domain_Should_NotDependOnFeaturesEndpointsOrInfrastructure()
    {
        TestResult result = Types.InAssembly(DomainAssembly)
            .That().ResideInNamespace(Namespaces.Domain)
            .ShouldNot().HaveDependencyOnAny(
                Namespaces.Features,
                Namespaces.Endpoints,
                Namespaces.Infrastructure)
            .GetResult();

        result.IsSuccessful.ShouldBeTrue(result.Describe());
    }

    [Fact]
    public void Abstractions_Should_NotDependOnFeaturesEndpointsOrInfrastructure()
    {
        TestResult result = Types.InAssembly(ApplicationAssembly)
            .That().ResideInNamespace(Namespaces.Abstractions)
            .ShouldNot().HaveDependencyOnAny(
                Namespaces.Features,
                Namespaces.Endpoints,
                Namespaces.Infrastructure)
            .GetResult();

        result.IsSuccessful.ShouldBeTrue(result.Describe());
    }

    [Fact]
    public void Features_Should_NotDependOnEndpointsOrInfrastructure()
    {
        TestResult result = Types.InAssembly(ApplicationAssembly)
            .That().ResideInNamespace(Namespaces.Features)
            .ShouldNot().HaveDependencyOnAny(
                Namespaces.Endpoints,
                Namespaces.Infrastructure)
            .GetResult();

        result.IsSuccessful.ShouldBeTrue(result.Describe());
    }

    [Fact]
    public void Infrastructure_Should_NotDependOnEndpoints()
    {
        TestResult result = Types.InAssembly(InfrastructureAssembly)
            .That().ResideInNamespace(Namespaces.Infrastructure)
            .ShouldNot().HaveDependencyOn(Namespaces.Endpoints)
            .GetResult();

        result.IsSuccessful.ShouldBeTrue(result.Describe());
    }
}
