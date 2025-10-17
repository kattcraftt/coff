namespace coff.API.SharedKernel.Domain.Categories;

public sealed class Category : Entity
{
    public Guid Id { get; set; }
    public string Name { get; set; }
    public Guid UserId { get; set; }
}
