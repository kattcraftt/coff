using coff.API.Abstractions.Messaging;

namespace coff.API.Features.Categories.Commands.DeleteCategory;

public sealed record DeleteCategoryCommand(Guid CategoryId) : ICommand;
