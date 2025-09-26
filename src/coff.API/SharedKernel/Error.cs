using coff.API.SharedKernel.Domain;

namespace coff.API.SharedKernel;

public record Error
{
    public static readonly Error None = new(string.Empty, string.Empty, ErrorType.Failure);
    public static readonly Error NullValue = new(
        "General.Null",
        "Null value was provided",
        ErrorType.Failure);

    public Error(string code, string description, ErrorType type)
    {
        Code = code;
        Description = description;
        Type = type;
    }

    public string Code { get; }

    public string Description { get; }

    public ErrorType Type { get; }

    public static Error Failure(string code, string description) =>
        new(code, description, ErrorType.Failure);

    public static Error NotFound(string code, string description) =>
        new(code, description, ErrorType.NotFound);

    public static Error Problem(string code, string description) =>
        new(code, description, ErrorType.Problem);

    public static Error Conflict(string code, string description) =>
        new(code, description, ErrorType.Conflict);
    
    /* Factory for multiple errors (e.g., from Identity or FluentValidation)*/
    public static IReadOnlyList<Error> From(IEnumerable<(string Code, string Description)> errors, ErrorType type = ErrorType.Failure) =>
        errors.Select(error => new Error(error.Code, error.Description, type)).ToList();
}
