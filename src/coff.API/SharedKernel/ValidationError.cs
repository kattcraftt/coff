﻿namespace coff.API.SharedKernel;

public sealed record ValidationError : Error
{
    public ValidationError(IEnumerable<Error> errors)
        : base(
            "Validation.General",
            "One or more validation errors occurred",
            ErrorType.Validation)
    {
        Errors = errors.ToArray();
    }

    public IReadOnlyList<Error> Errors { get; }

    public static ValidationError FromResults(IEnumerable<Result> results) =>
        new(results.Where(r => r.IsFailure).SelectMany(r => r.Errors));
}
