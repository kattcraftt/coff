﻿namespace coff.API.SharedKernel;

public interface IDateTimeProvider
{
    DateTime UtcNow { get; }
}
