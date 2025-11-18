import Link from "next/link";
import Image from "next/image";

export const HeaderLogo = () => {
    return (
        <Link href="/">
            <div className="items-center hidden lg:flex">
                <Image src="/coff-logo.svg" alt="coff-logo" width={50} height={50} />
                <p className="font-semibold text-black text-2xl ml-2.5">
                    coff
                </p>
            </div>
        </Link>
    );
};