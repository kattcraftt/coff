"use client";

import * as React from "react";
import { Button } from "./button";
import { Spinner } from "./spinner";
import { cn } from "@/lib/utils";

export interface LoadingButtonProps extends React.ComponentProps<typeof Button> {
    isLoading?: boolean;
    loadingText?: string;
}

export const LoadingButton = React.forwardRef<HTMLButtonElement, LoadingButtonProps>(
    ({ isLoading, loadingText, children, className, disabled, ...props }, ref) => {
        return (
            <Button
                ref={ref}
                disabled={disabled || isLoading}
                className={cn("relative", className)}
                {...props}
            >
                {isLoading && (
                    <span className="mr-2 inline-flex">
                        <Spinner label={loadingText ?? "Loading"} />
                    </span>
                )}
                <span className={cn(isLoading ? "opacity-80" : undefined)}>{children}</span>
            </Button>
        );
    }
);
LoadingButton.displayName = "LoadingButton";

export default LoadingButton;
