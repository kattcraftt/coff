"use client";

import { Button } from "@/components/ui/button";

import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";

import React from "react";

interface AuthLayoutProps {
    children: React.ReactNode;
};
const AuthLayout = ({ children }: AuthLayoutProps) => {
    const pathname = usePathname();
    const isSignIn = pathname === "/login";

    return (
        <main className="bg-brand-mint min-h-screen">
            <div className="mx-auto max-w-screen-2xl p-6">
                <nav className="flex justify-between items-center">
                    <Image src="/coff-custom-logo.svg" alt="coff-logo" width={125} height={50} />
                    <Button asChild variant={"secondary"} size={"xl"}>
                        <Link href={isSignIn ? "register" : "login"}>
                            {isSignIn ? "Register" : "Login"}
                        </Link>
                    </Button>
                </nav>
                <div className="flex min-h-[calc(100vh-96px)] flex-col items-center justify-center pt-6 md:pt-10">
                    {children}
                </div>
            </div>
        </main>
    );
};

export default AuthLayout;