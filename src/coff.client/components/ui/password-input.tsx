"use client";

import * as React from "react";
import { Eye, EyeOff } from "lucide-react";
import { Input } from "./input";
import { cn } from "@/lib/utils";

export interface PasswordInputProps extends React.ComponentProps<typeof Input> {
    toggleLabel?: string;
}

export const PasswordInput = React.forwardRef<HTMLInputElement, PasswordInputProps>(
    ({ className, toggleLabel = "Toggle password visibility", ...props }, ref) => {
        const [show, setShow] = React.useState(false);
        const effectiveType = show ? "text" : "password";

        return (
            <div className="relative">
                <Input
                    ref={ref}
                    type={effectiveType}
                    className={cn("pr-10", className)}
                    {...props}
                />
                <button
                    type="button"
                    onClick={() => setShow((s) => !s)}
                    className="absolute inset-y-0 right-0 flex items-center px-3 text-muted-foreground hover:text-foreground"
                    aria-label={toggleLabel}
                    aria-pressed={show}
                    tabIndex={0}
                >
                    {show ? <EyeOff className="size-4" /> : <Eye className="size-4" />}
                    <span className="sr-only">{show ? "Hide password" : "Show password"}</span>
                </button>
            </div>
        );
    }
);
PasswordInput.displayName = "PasswordInput";

export default PasswordInput;
