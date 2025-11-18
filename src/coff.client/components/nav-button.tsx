import Link from 'next/link';

import { cn } from "@/lib/utils";
import { Button } from "./ui/button";


type Props = {
    href: string;
    label: string;
    isActive: boolean;
};

export const NavButton = ({
    href,
    label,
    isActive
}: Props) => {
    return (
        <Button
            asChild
            size="sm"
            variant="outline"
            className={cn(
                "w-full lg:w-auto justify-between font-normal hover:bg-white/70 hover:text-black border-none focus-visible:ring-offset-0 focus-visible:ring-transparent outline-none text-black focus:bg-white/80 transition",
                isActive ? "bg-white/60 text-black" : "bg-transparent",
            )}
        >
            <Link href={href}>
                {label}
            </Link>
        </Button>
    );
};