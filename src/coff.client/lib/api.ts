import axios, { AxiosError, AxiosHeaders, AxiosRequestConfig, Method } from "axios";
import { ApiError } from "./errors";
import { getToken, clearToken } from "./auth/token";

const api = axios.create({
    baseURL: process.env.NEXT_PUBLIC_API_URL,
    withCredentials: false,
    timeout: 10000,
});

// Attach Bearer token (JWT) when present
api.interceptors.request.use((config) => {
    const token = getToken();
    if (token) {
        const headers = config.headers instanceof AxiosHeaders
            ? config.headers
            : new AxiosHeaders(config.headers);
        headers.set("Authorization", `Bearer ${token}`);
        config.headers = headers;
    }
    return config;
});

// Normalize API errors so callers can rely on consistent Error.message
api.interceptors.response.use(
    (resp) => resp,
    (error: AxiosError<unknown>) => {
        // If ASP.NET returns ProblemDetails or a custom shape, pick a useful message
        const status = error.response?.status;
        const data: unknown = error.response?.data;

        const isRecord = (v: unknown): v is Record<string, unknown> =>
            typeof v === "object" && v !== null;

        let message = "Request failed";
        if (typeof data === "string") {
            message = data;
        } else if (isRecord(data)) {
            // RFC 7807 ProblemDetails or custom { message }
            const description = data["description"];
            const detail = data["detail"];
            const title = data["title"];
            const msg = data["message"];

            if (typeof description === "string") message = description;
            else if (typeof detail === "string") message = detail;
            else if (typeof title === "string") message = title;
            else if (typeof msg === "string") message = msg;
        } else if (status) {
            message = `${status} ${error.response?.statusText || "Error"}`;
        }

        // Handle 401/403 globally (token expired/invalid)
        if (status === 401 || status === 403) {
            clearToken();
        }

        return Promise.reject(new ApiError(message, status, data));
    }
);

/**
 * Generic JSON request wrapper
 * @param method - HTTP method (GET, POST, etc.)
 * @param url - API endpoint
 * @param data - Request body
 */
export async function apiRequest<T>(
    method: Method,
    url: string,
    data?: unknown
): Promise<T> {
    const headers: Record<string, string> = {
        "Content-Type": "application/json",
        Accept: "application/json, application/*+json",
    };

    const config: AxiosRequestConfig = {
        method,
        url,
        data,
        headers,
    };

    const response = await api.request<T>(config);
    return response.data;
}

export default api;