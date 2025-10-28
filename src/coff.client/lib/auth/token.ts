const KEY = "access_token";

export function getToken(): string | null {
    if (typeof window === "undefined") return null;
    try {
        return window.localStorage.getItem(KEY);
    } catch {
        return null;
    }
}

export function setToken(token: string): void {
    if (typeof window === "undefined") return;
    try {
        window.localStorage.setItem(KEY, token);
    } catch {
        // ignore write errors (private mode, quota, etc.)
    }
}

export function clearToken(): void {
    if (typeof window === "undefined") return;
    try {
        window.localStorage.removeItem(KEY);
    } catch {
        // ignore
    }
}
