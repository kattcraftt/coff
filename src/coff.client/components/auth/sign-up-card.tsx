"use client";
import { z } from "zod";
import { FcGoogle } from "react-icons/fc";
import { FaGithub } from "react-icons/fa";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";

import { LineSeparator } from "../line-separator";
import { Button } from "../ui/button";
import { LoadingButton } from "../ui/loading-button";
import { LoadingOverlay } from "../ui/loading-overlay";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "../ui/card";
import { Input } from "../ui/input";
import { PasswordInput } from "../ui/password-input";
import {
    Form,
    FormControl,
    FormField,
    FormItem,
    FormMessage
} from "../ui/form";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { register as registerUser } from "@/lib/auth/auth";
import { ApiError, getFieldErrors } from "@/lib/errors";

const formSchema = z.object({
    email: z.string().email(),
    password: z.string().min(8, "Minimum 8 characters required"),
    confirmPassword: z.string(),
})
    .refine((data) => data.password === data.confirmPassword, {
        message: "Passwords do not match",
        path: ["confirmPassword"],
    });
export const SignUpCard = () => {
    const router = useRouter();
    const form = useForm<z.infer<typeof formSchema>>({
        resolver: zodResolver(formSchema),
        defaultValues: {
            email: "",
            password: "",
            confirmPassword: "",
        },
    });

    const onSubmit = async (values: z.infer<typeof formSchema>) => {
        // Map to API DTO (omit confirmPassword)
        try {
            await registerUser({
                email: values.email,
                password: values.password,
                confirmPassword: values.confirmPassword
            });
            // Redirect to login after successful registration
            router.push("/sign-in");
        } catch (err) {
            const fieldErrors = getFieldErrors(err);
            if (fieldErrors) {
                // Case-insensitive mapping to form fields (ASP.NET ModelState often uses PascalCase)
                const mapKey = (k: string) => k.toLowerCase();
                const fields = Object.keys(values).reduce<Record<string, string>>((acc, k) => {
                    acc[mapKey(k)] = k;
                    return acc;
                }, {});
                for (const [serverKey, messages] of Object.entries(fieldErrors)) {
                    const msg = messages?.[0];
                    const clientKey = fields[mapKey(serverKey)];
                    if (clientKey && msg) {
                        // @ts-expect-error dynamic key is ok for react-hook-form here
                        form.setError(clientKey, { message: msg });
                    }
                }
            }
            const message = err instanceof ApiError ? err.message : "Registration failed";
            if (!fieldErrors) form.setError("root", { message });
        }
    };

    return (
        <Card className="w-full h-full md:w-[487px] border-none shadow-none rounded-2xl">
            <CardHeader className="items-center justify-center text-center p-5">
                <CardTitle className="text-2xl">
                    Create Account
                </CardTitle>
                <CardDescription>
                    By signing up, you agree to our{" "}
                    <Link href="/privacy">
                        <span className="text-blue-700">Privacy Policy</span>
                    </Link>{" "}
                    and{" "}
                    <Link href="/privacy">
                        <span className="text-blue-700">Terms of Service</span>
                    </Link>
                </CardDescription>
            </CardHeader>
            <div className="px-7">
            </div>
            <CardContent className="p-7 relative">
                <LoadingOverlay show={form.formState.isSubmitting} label="Creating account" />
                <Form {...form}>
                    <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
                        <FormField
                            name="email"
                            control={form.control}
                            render={({ field }) => (
                                <FormItem>
                                    <FormControl>
                                        <Input
                                            type="email"
                                            placeholder="Email"
                                            {...field}
                                        />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />
                        <FormField
                            name="password"
                            control={form.control}
                            render={({ field }) => (
                                <FormItem>
                                    <FormControl>
                                        <PasswordInput
                                            placeholder="Password"
                                            autoComplete="new-password"
                                            {...field}
                                        />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />
                        <FormField
                            name="confirmPassword"
                            control={form.control}
                            render={({ field }) => (
                                <FormItem>
                                    <FormControl>
                                        <PasswordInput
                                            placeholder="Confirm Password"
                                            autoComplete="new-password"
                                            {...field}
                                        />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />
                        {form.formState.errors.root?.message && (
                            <p className="text-sm text-red-600">
                                {form.formState.errors.root.message}
                            </p>
                        )}
                        <LoadingButton isLoading={form.formState.isSubmitting} size="lg" className="w-full" loadingText="Creating account">
                            Register
                        </LoadingButton>
                    </form>
                </Form>
            </CardContent>
            <div className="px-7">
                <LineSeparator />
            </div>
            <CardContent className="p-7 flex flex-col gap-y-4">
                <Button
                    disabled={false}
                    variant={"secondary"}
                    size="lg"
                    className="w-full"
                >
                    <FcGoogle className="mr-2 size-5" />
                    Google
                </Button>
                <Button
                    disabled={false}
                    variant={"secondary"}
                    size="lg"
                    className="w-full"
                >
                    <FaGithub className="mr-2 size-5" />
                    Github
                </Button>
            </CardContent>
            <CardContent className="p-4 flex items-center justify-center">
                <p>
                    Already have an account?
                    <Link href={"/login"}>
                        <span className="text-blue-700">&nbsp;Login</span>
                    </Link>
                </p>
            </CardContent>
        </Card>
    );
};