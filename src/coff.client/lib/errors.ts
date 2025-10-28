export class ApiError extends Error {
    status?: number;
    data?: unknown;
    constructor(message: string, status?: number, data?: unknown) {
        super(message);
        this.name = "ApiError";
        this.status = status;
        this.data = data;
    }
}

// Extract ASP.NET Core ProblemDetails validation errors
// Shape: { title, status, errors: { [key: string]: string[] } }
export function getFieldErrors(err: unknown): Record<string, string[]> | undefined {
    if (!(err instanceof ApiError)) return undefined;
    const v = err.data;
    if (typeof v !== "object" || v === null) return undefined;
    const maybeErrors = (v as Record<string, unknown>)["errors"];
    if (!maybeErrors || typeof maybeErrors !== "object") return undefined;
    const record: Record<string, string[]> = {};
    for (const [k, val] of Object.entries(maybeErrors as Record<string, unknown>)) {
        if (Array.isArray(val)) {
            record[k] = val.filter((x): x is string => typeof x === "string");
        }
    }
    return Object.keys(record).length ? record : undefined;
}
