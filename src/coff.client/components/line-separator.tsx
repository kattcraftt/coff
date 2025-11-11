import { cn } from "@/lib/utils";

interface LineSeparatorProps {
    className?: string;
    text?: string;
    color?: string;
}

export const LineSeparator = ({
    className,
    text = "or",
    color = "#111111"
}: LineSeparatorProps) => {
    return (
        <div className={cn("w-full flex items-center", className)}>
            <div className="flex-1 h-[2px]" style={{ backgroundColor: color }} />
            <span className="mx-3 text-sm text-muted-foreground">{text}</span>
            <div className="flex-1 h-[2px]" style={{ backgroundColor: color }} />
        </div>
    );
};

export default LineSeparator;
