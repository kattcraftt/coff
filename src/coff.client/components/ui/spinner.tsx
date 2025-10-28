"use client";

import * as React from "react";
import { Loader2 } from "lucide-react";
import { cn } from "@/lib/utils";

export type SpinnerProps = React.ComponentProps<typeof Loader2> & {
    label?: string;
};

export function Spinner({ className, label = "Loading", ...props }: SpinnerProps) {
    return (
        <span className={cn("inline-flex items-center", className)} aria-live="polite" aria-busy="true">
            <Loader2 className={cn("size-4 animate-spin")} {...props} />
            <span className="sr-only">{label}</span>
        </span>
    );
}

export default Spinner;
