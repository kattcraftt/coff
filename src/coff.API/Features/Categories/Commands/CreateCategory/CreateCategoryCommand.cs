using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Categories.Commands.CreateCategory;

public sealed record CreateCategoryCommand(string Name) : ICommand<Guid>;
