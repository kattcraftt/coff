"use client";

import * as React from "react";
import { cn } from "@/lib/utils";
import { Spinner } from "./spinner";

export interface LoadingOverlayProps {
    show: boolean;
    label?: string;
    className?: string;
    blur?: boolean;
    fullscreen?: boolean;
}

export function LoadingOverlay({ show, label = "Loading", className, blur = true, fullscreen = false }: LoadingOverlayProps) {
    if (!show) return null;
    const content = (
        <div
            className={cn(
                "pointer-events-none absolute inset-0 z-50 flex items-center justify-center",
                blur && "backdrop-blur-sm",
                className
            )}
            aria-live="polite"
            aria-busy="true"
            role="status"
        >
            <div className="rounded-md bg-background/70 p-3 shadow-sm ring-1 ring-border">
                <Spinner label={label} />
            </div>
        </div>
    );
    if (fullscreen) {
        return (
            <div className="fixed inset-0 z-50">
                {content}
            </div>
        );
    }
    return content;
}

export default LoadingOverlay;
