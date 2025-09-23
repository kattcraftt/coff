import axios, { AxiosRequestConfig, Method } from "axios";

const api = axios.create({
    baseURL: process.env.NEXT_PUBLIC_API_URL,
    withCredentials: true,
    timeout: 10000,
});

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