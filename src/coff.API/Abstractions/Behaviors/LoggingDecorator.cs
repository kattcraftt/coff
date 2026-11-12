using coff.API.Abstractions.Messaging;
using coff.API.SharedKernel;
using Serilog.Context;

namespace coff.API.Abstractions.Behaviors;

internal static class LoggingDecorator
{
    internal sealed class CommandHandler<TCommand, TResponse>(
        ICommandHandler<TCommand, TResponse> innerHandler,
        ILogger<CommandHandler<TCommand, TResponse>> logger)
        : ICommandHandler<TCommand, TResponse>
        where TCommand : ICommand<TResponse>
    {
        private static readonly string CommandName = typeof(TCommand).Name;

        public async Task<Result<TResponse>> Handle(TCommand command, CancellationToken cancellationToken)
        {
            logger.LogInformation("Processing command {Command}", CommandName);

            Result<TResponse> result = await innerHandler.Handle(command, cancellationToken);

            if (result.IsSuccess)
            {
                logger.LogInformation("Completed command {Command}", CommandName);
            }
            else
            {
                using (LogContext.PushProperty("Error", result.Errors, true))
                {
                    logger.LogError("Completed command {Command} with error", CommandName);
                }
            }

            return result;
        }
    }

    internal sealed class CommandBaseHandler<TCommand>(
        ICommandHandler<TCommand> innerHandler,
        ILogger<CommandBaseHandler<TCommand>> logger)
        : ICommandHandler<TCommand>
        where TCommand : ICommand
    {
        private static readonly string CommandName = typeof(TCommand).Name;

        public async Task<Result> Handle(TCommand command, CancellationToken cancellationToken)
        {
            logger.LogInformation("Processing command {Command}", CommandName);

            Result result = await innerHandler.Handle(command, cancellationToken);

            if (result.IsSuccess)
            {
                logger.LogInformation("Completed command {Command}", CommandName);
            }
            else
            {
                using (LogContext.PushProperty("Error", result.Errors, true))
                {
                    logger.LogError("Completed command {Command} with error", CommandName);
                }
            }

            return result;
        }
    }

    internal sealed class QueryHandler<TQuery, TResponse>(
        IQueryHandler<TQuery, TResponse> innerHandler,
        ILogger<QueryHandler<TQuery, TResponse>> logger)
        : IQueryHandler<TQuery, TResponse>
        where TQuery : IQuery<TResponse>
    {
        private static readonly string QueryName = typeof(TQuery).Name;

        public async Task<Result<TResponse>> Handle(TQuery query, CancellationToken cancellationToken)
        {
            logger.LogInformation("Processing query {Query}", QueryName);

            Result<TResponse> result = await innerHandler.Handle(query, cancellationToken);

            if (result.IsSuccess)
            {
                logger.LogInformation("Completed query {Query}", QueryName);
            }
            else
            {
                using (LogContext.PushProperty("Error", result.Errors, true))
                {
                    logger.LogError("Completed query {Query} with error", QueryName);
                }
            }

            return result;
        }
    }
}
