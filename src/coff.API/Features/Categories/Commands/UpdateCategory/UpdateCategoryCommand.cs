using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Categories.Commands.UpdateCategory;

public sealed record UpdateCategoryCommand(Guid CategoryId, string Name) : ICommand;
