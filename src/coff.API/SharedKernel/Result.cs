using System.Diagnostics.CodeAnalysis;

namespace coff.API.SharedKernel;

public class Result
{
    public Result(bool isSuccess, IReadOnlyList<Error> errors)
    {
        if (isSuccess && errors.Any() ||
            !isSuccess && errors.Count == 0)
        {
            throw new ArgumentException("Invalid error", nameof(errors));
        }

        IsSuccess = isSuccess;
        Errors = errors;
    }

    public bool IsSuccess { get; }

    public bool IsFailure => !IsSuccess;

    public IReadOnlyList<Error> Errors { get; }

    public Error Error => Errors[0];

    public static Result Success() => new(true, Array.Empty<Error>());

    public static Result<TValue> Success<TValue>(TValue value) =>
        new(value, true, Array.Empty<Error>());

    public static Result Failure(Error error) => new(false, new[] { error });

    public static Result Failure(IEnumerable<Error> errors) =>
        new(false, errors.ToList());
    
    public static Result<TValue> Failure<TValue>(Error error) =>
        new(default, true, new[] { error });

    public static Result<TValue> Failure<TValue>(IEnumerable<Error> errors) =>
        new(default, false, errors.ToList());
}

public class Result<TValue> : Result
{
    private readonly TValue? _value;

    public Result(TValue? value, bool isSuccess, IReadOnlyList<Error> errors)
        : base(isSuccess, errors)
    {
        _value = value;
    }

    [NotNull]
    public TValue Value => IsSuccess
        ? _value!
        : throw new InvalidOperationException("The value of a failure result can't be accessed.");

    public static implicit operator Result<TValue>(TValue? value) =>
        value is not null ? Success(value) : Failure<TValue>(Error.NullValue);

    public static Result<TValue> ValidationFailure(IReadOnlyList<Error> errors) =>
        new(default, false, errors);
}
