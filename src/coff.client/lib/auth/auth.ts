import { apiRequest } from "../api";
import { setToken, clearToken } from "./token";

const AUTH_BASE = "/users";

export type RegisterRequest = {
    email: string;
    password: string;
    confirmPassword: string;
};

export type LoginRequest = {
    email: string;
    password: string;
};

export type UserDto = {
    id: string;
    email: string;
    // add other fields your API returns
};

export type LoginResponse = {
    user?: UserDto;
    token: string; // ASP.NET returns JWT
};

export async function register(data: RegisterRequest): Promise<void> {
    await apiRequest<void>("POST", `${AUTH_BASE}/register`, data);
}

export async function login(data: LoginRequest): Promise<LoginResponse> {
    const res = await apiRequest<LoginResponse>("POST", `${AUTH_BASE}/login`, data);
    if (res.token) {
        setToken(res.token);
    }
    return res;
}

export async function logout(): Promise<void> {
    try {
        await apiRequest<void>("POST", `${AUTH_BASE}/logout`);
    } finally {
        clearToken();
    }
}
