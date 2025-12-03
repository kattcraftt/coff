using System.Reflection;
using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel.Domain.Users;
using coff.API.SharedKernel.Infrastructure.Database;
using coff.API;

namespace ArchitectureTests;

public abstract class BaseTest
{
    protected static readonly Assembly DomainAssembly = typeof(User).Assembly;
    protected static readonly Assembly ApplicationAssembly = typeof(ICommand).Assembly;
    protected static readonly Assembly InfrastructureAssembly = typeof(ApplicationDbContext).Assembly;
    protected static readonly Assembly PresentationAssembly = typeof(Program).Assembly;
}
