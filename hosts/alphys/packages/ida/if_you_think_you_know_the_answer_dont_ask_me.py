# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.


# so haii i rewrited original keygen and patcher bcuz ida already changed format (fuck it)
# 29 oct 2026 
# bitracker
import argparse
import hashlib
import json
import os
import shutil
import sys
from datetime import datetime


def json_stringify_alphabetical(obj: dict):
    return json.dumps(obj, sort_keys=True, separators=(",", ":"), ensure_ascii=False)


def buf_to_bigint(buf: bytes):
    return int.from_bytes(buf, byteorder="little")


def bigint_to_buf(i: int):
    return i.to_bytes((i.bit_length() + 7) // 8, byteorder="little")


PUBLIC_EXPONENT = 19
KEY_SALT = bytes.fromhex("686578726179732d6c6f63616c2d6c6963656e73652d7273612d7631")
FORMAT_CHECK_BYTES = bytes.fromhex(
    "80bc24fb0200007f75530fb68424f3020000440fb6ac24f702000083f0fb"
    "4183f5ef0fb6c80fb6842403030000450fb6ed83f0c2"
)


def modulus_layout():
    # ida shuffles the 64 words of n and xors each with a pos depedent mask.
    # undo that to read its key, then reverse the process to store ours
    # the mask calc wraps at 32 bits, just like the compiled code
    # ~ bitracker
    for index in range(64):
        position = (11 + 37 * index) & 63
        value = ((index * 73244475) ^ (668265261 * position)) & 0xFFFFFFFF
        mask = (((value ^ 0x9E3779B9) >> 16) ^ value ^ 0x79B9) & 0xFFFF
        yield index, position, mask


def decode_modulus(encoded: bytes) -> bytes:
    words = [0] * 64
    for index, position, mask in modulus_layout():
        words[position] = int.from_bytes(encoded[2 * index:2 * index + 2], "little") ^ mask
    return b"".join(word.to_bytes(2, "little") for word in words)


def encode_modulus(modulus: bytes) -> bytes:
    encoded = bytearray(128)
    for index, position, mask in modulus_layout():
        word = int.from_bytes(modulus[2 * position:2 * position + 2], "little") ^ mask
        encoded[2 * index:2 * index + 2] = word.to_bytes(2, "little")
    return bytes(encoded)


def key_digest(modulus: bytes) -> bytes:
    return hashlib.sha256(
        KEY_SALT + PUBLIC_EXPONENT.to_bytes(160, "little") + modulus.ljust(160, b"\0")
    ).digest()


def format_check_bytes(digest: bytes) -> bytes:
    # ida uses bytes of the key hash to decide how to read the sig.
    # changing n changes those bytes too
    # ida then verifies the sig and payload hash with our public key
    # ~ bitracker
    result = bytearray(FORMAT_CHECK_BYTES)
    result[7] = digest[11]
    result[FORMAT_CHECK_BYTES.index(bytes.fromhex("83f0fb")) + 2] = digest[3] ^ 128
    result[FORMAT_CHECK_BYTES.index(bytes.fromhex("4183f5ef")) + 3] = digest[7] ^ 95
    result[FORMAT_CHECK_BYTES.index(bytes.fromhex("83f0c2")) + 2] = digest[19] ^ 127
    return bytes(result)


class RSA:
    def __init__(self):
        self.hexrays_modulus_bytes = bytes.fromhex(
            "29f4481f796f9f66f2ff13cc4ab5b54f60845db603ba2c0bac8a9bc4b6cbdefc5c62bfc2f5ee850ac45ea97ad347e8b56dba5085af8c8aad9cc2ec626ca78a068006d658f68651da31a0a77c65a70ed73a40d53b08edd403c095aa0bcffa52f313ebcacaaa2ce5024a4e2b9aa70fc6092f38ae094d71e43f7690b5ddd3e9e4f7"
        )
        self.signing_modulus = buf_to_bigint(bytes.fromhex(
            "53d268c00a4803d185cf37f44667c060b3079391b804962df392501aeb05e1d4c2e8ac3ec3aa2efea258148650112a496405faa87b6f36e899feaac5379b3405710af82f6fbb1f827c27fd128b4d70ce424c9606588aa486ed731aca5950a128ada72518d0633dbaa10e0626067bf548d2ded4d1a5809ff04cf6864e4eb98c8a"
        ))
        self.private_key = buf_to_bigint(bytes.fromhex(
            "43d9f696731f8daca29997201dfbb2f85be76bac45d8fe019ab9563cb2095335abc99f90dde59135d9025154f62af48170528aabf944c5f23c4b15e2746083e1cb6c9c8de4f438b724d940aa0fdff8f8f8cc755a501f9264a421dadf9ccf91378cd3a069e9f9eaacebfc31f6c3c1f3334193820df575ebaf809edb77b46b5e0d"
        ))
        modulus = self.signing_modulus.to_bytes(128, "little")
        self.patched_modulus_bytes = encode_modulus(modulus)
        original_digest = key_digest(decode_modulus(self.hexrays_modulus_bytes))
        digest = key_digest(modulus)
        self.signature_pad = bytes(a ^ b for a, b in zip(original_digest, digest))
        self.format_patch = format_check_bytes(digest)

        # the explanation below describes the old prime-modulus patch.

        # Small update: A lot of people were curious how was the private key generated, so let me explain.
        # You know how RSA works, right?
        # The private key usually consists of two or more prime numbers, and the public key is the product of those prime numbers.
        # p - prime number 1
        # q - prime number 2
        # n = p * q - public modulus
        # e - public exponent
        # They are being used to compute a private exponent d, which in this case is used to sign the payload.
        # d = e^-1 mod (p-1)(q-1)
        # Did you see what exactly was done to the public modulus?
        # It's a prime number! But RSA is usually used with two prime numbers, right?
        # And the only reason RSA is secure is because we assume that it's very hard to find the factors of a public modulus.
        # And if n is a prime number, then the only factor is n - which means - RSA essentially becomes a symmetric cipher.
        # So how do we get the private key? It's simple: d = e^-1 mod (n-1)
        # ~ alula

        # here we use two random 512-bit primes and keep ida's e = 19.
        # our private exponent is d = inverse(e, lcm(p - 1, q - 1)).
        # ida also mixes the key hash into the signature padding, so we xor
        # the original and our key hashes to get the matching padding mask.
        # ~ bitracker

    def encrypt(self, message: bytes):
        signature = pow(
            int.from_bytes(message, byteorder="big"),
            self.private_key,
            self.signing_modulus,
        )
        return signature.to_bytes(128, byteorder="little")


def create_license(
    name: str,
    license_type: str,
    owner="lain@iwakura.page",
    start_date: str | None = None,
    end_date: str | None = None,
):
    start_date = start_date or "2024-08-10"
    end_date = end_date or "2034-08-01"

    id = "48-2137-ACAB-69"
    license = {
        "header": {"version": 1},
        "payload": {
            "name": owner,
            "email": owner,
            "licenses": [
                {
                    "description": "Lain Iwakura",
                    "edition_id": "ida-pro",
                    "id": id,
                    "product_id": "IDAPRO",
                    "product_version": "9.5",
                    "license_type": license_type,
                    "product": "IDA",
                    "seats": 1,
                    "start_date": f"{start_date} 00:00:00",
                    "end_date": f"{end_date} 23:59:59",
                    "issued_on": "2025-07-20 00:00:00",
                    "owner": name,  # should be email, but this is for custom text in about dialog
                    "add_ons": get_addons(
                        owner=id,
                        start_date="2025-07-20 00:00:00",
                        end_date=f"{end_date} 23:59:59",
                    ),
                    "features": [],
                }
            ],
        },
    }

    return license


def get_addons(owner: str, start_date: str, end_date: str) -> list[dict]:
    # Not used anymore since 9.0
    # platforms = [
    #     "W",  # Windows
    #     "L",  # Linux
    #     "M",  # macOS
    # ]
    addons = [
        "LUMINA", "TEAMS",
        "HEXX86", "HEXX64", "HEXARM", "HEXARM64",
        "HEXMIPS", "HEXMIPS64", "HEXPPC", "HEXPPC64",
        "HEXRV", "HEXRV64", "HEXARC", "HEXARC64",
        "HEXV850", "HEXDALVIK", "HEXTRICORE", "HEXQDSP6", "MALWARE",
        # Cloud, but obviously we can't use it cracked
        # "HEXCX86",
        # "HEXCX64",
        # "HEXCARM",
        # "HEXCARM64",
        # "HEXCMIPS",
        # "HEXCMIPS64",
        # "HEXCPPC",
        # "HEXCPPC64",
        # "HEXCRV",
        # "HEXCRV64",
        # "HEXCARC",
    ]

    result = []

    i = 0
    for addon in addons:
        i += 1
        result.append(
            {
                "id": f"48-1337-B00B-{i:02}",
                "code": addon,
                "owner": owner,
                "start_date": start_date,
                "end_date": end_date,
            }
        )
    # for addon in addons:
    #     for platform in platforms:
    #         i += 1
    #         result.append(
    #             {
    #                 "id": f"48-1337-DEAD-{i:02}",
    #                 "code": addon + platform,
    #                 "owner": owner,
    #                 "start_date": start_date,
    #                 "end_date": end_date,
    #             }
    #         )
    return result


def generate_license_file(license_data, filename="idapro.hexlic"):
    license_data["signature"] = sign_hexlic(license_data["payload"])
    serialized = json_stringify_alphabetical(license_data)

    with open(filename, "w", encoding="utf-8") as f:
        f.write(serialized)

    print(f"Saved new license to {filename}!")
    return True


def patch_ida_files(apply=False):
    """Patch all IDA files"""
    files_to_patch = [
        "ida32.dll",
        "ida.dll",
        "libida32.so",
        "libida.so",
        "libida32.dylib",
        "libida.dylib",
    ]

    success_count = 0
    for filename in files_to_patch:
        if not os.path.exists(filename):
            continue
        if not generate_patched_dll(filename, apply):
            return -1
        success_count += 1

    if apply:
        # if we're on macOS, try to run codesign
        if sys.platform == "darwin":
            parent_path = os.path.abspath(os.curdir)
            if not parent_path.endswith("Contents/MacOS"):
                print(
                    "Error: Unexpected path structure. In order to re-sign the bundle, this script should be run from xxx.app/Contents/MacOS/"
                )
                return success_count

            bundle_dir = os.path.abspath(os.path.join(parent_path, "../.."))

            try:
                result = os.system(f"xattr -c '{bundle_dir}'")
                if result != 0:
                    print(
                        "Error: Failed to clear extended attributes on the IDA bundle."
                    )
            except Exception as e:
                print(f"Error while trying to clear extended attributes: {e}")

            try:
                result = os.system(f"codesign --verbose -f -s - --deep '{bundle_dir}'")
                if result != 0:
                    print("Error: Failed to re-sign the IDA bundle.")
            except Exception as e:
                print(f"Error while trying to re-sign the IDA bundle: {e}")

    return success_count


rsa = RSA()


SIGNATURE_PAD = rsa.signature_pad * 4


def sign_hexlic(payload: dict) -> str:
    # ida9.5 hashes canonical utf-8 json including the payload wrapper
    # the digest goes at off 95 in a 127-byte block, then gets xor paddin
    # rsa reads the block as be; key constants and the final 128-byte
    # signature use le order
    # ~bitracker
    serialized = json_stringify_alphabetical({"payload": payload}).encode("utf-8")
    digest = hashlib.sha256(serialized).digest()
    block = bytearray(127)
    block[95:127] = digest
    for index in range(len(block)):
        block[index] ^= SIGNATURE_PAD[index]
    if block[0] == 0:
        block[0] = 1
    return rsa.encrypt(block).hex().upper()


def generate_patched_dll(filename, apply=False):
    if not os.path.exists(filename):
        # print(f"Didn't find {filename}, skipping patch generation")
        return False

    with open(filename, "rb") as f:
        data = f.read()

        original_keys = data.count(rsa.hexrays_modulus_bytes)
        patched_keys = data.count(rsa.patched_modulus_bytes)
        original_format = data.count(FORMAT_CHECK_BYTES)
        patched_format = data.count(rsa.format_patch)
        if original_keys == 0 and patched_keys > 0 and patched_format == 1:
            print(f"{filename} looks to be already patched :)")
            return True
        if original_keys == 0 or patched_keys != 0 or original_format != 1:
            print(f"{filename}: unsupported key or verifier layout; use a clean ida9.5 library.")
            return False

        data = data.replace(rsa.hexrays_modulus_bytes, rsa.patched_modulus_bytes)
        data = data.replace(FORMAT_CHECK_BYTES, rsa.format_patch)

        patched_filename = f"{filename}.patched"
        with open(patched_filename, "wb") as f:
            f.write(data)

        print(f"Generated patch: {patched_filename}")

    if apply:
        # Check if file is writable
        try:
            with open(filename, "r+b"):
                pass
        except Exception:
            print(f"Error: {filename} is not writable. Cannot swap files.")
            return False

        backup_filename = f"{filename}.bak"
        try:
            if not os.path.exists(backup_filename):
                shutil.copy2(filename, backup_filename)
                print(f"Created backup: {backup_filename}")
            else:
                print(
                    f"Backup already exists: {backup_filename}, skipping backup creation."
                )

            # Replace original with patched
            shutil.move(patched_filename, filename)
            print(f"Swapped {filename} with patched version")
            return True
        except Exception as e:
            print(f"Error swapping files: {e}")
            return False
    else:
        print("To apply the patch, replace the original files with the patched files")
        return True


class ArgumentParserWithHelp(argparse.ArgumentParser):
    def error(self, message):
        sys.stderr.write("error: %s\n" % message)
        self.print_help()
        sys.exit(2)


def main():
    parser = ArgumentParserWithHelp(
        description="IDA Pro 9.x patcher and keygen",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --patch                   : Generate .patched files only
  %(prog)s --patch --apply           : Generate patches and apply them to current IDA installation
                                     : on macOS attempts to also re-sign the bundle
  %(prog)s --license                 : Generate license only
  %(prog)s --oneshot                 : Patch IDA then generate license - equivalent to running --patch --apply then --license
  %(prog)s --license --name "bnuuy"  : Custom name
  %(prog)s --oneshot --license-type floating --end-date 2030-12-31

How to use:
  1. Place this script in the directory where IDA is installed and all .dll/.so/.dylib files are located.
     On Windows it's C:\\Program Files\\IDA Professional 9.x\\
     On Linux it's ~/ida-pro-9.x/
     On macOS it's /Applications/IDA Professional 9.x.app/Contents/MacOS/
  2. You most likely just want to run the script with --oneshot option, which will do everything automatically.
  3. If you want run individual steps, see the options above.
        """,
    )

    mode_group = parser.add_mutually_exclusive_group(required=True)
    mode_group.add_argument(
        "--patch", action="store_true", help="Generate patched DLL files"
    )
    mode_group.add_argument(
        "--license", action="store_true", help="Generate license file only"
    )
    mode_group.add_argument(
        "--oneshot", action="store_true", help="Patch IDA files and generate license"
    )

    parser.add_argument(
        "--apply",
        action="store_true",
        help="Apply patches to original files (creates .bak backups)",
    )

    parser.add_argument(
        "--name",
        # idgaf what you do, but if you republish this script as your own without
        # any meaningful changes, you're just a skid
        #default="cracked by alula :3",
        default="meow mrrp nyawaw :3333 haii from bitracker",
        help="License holder name (default: %(default)s)",
    )
    parser.add_argument(
        "--license-type",
        choices=["named", "floating", "computer"],
        default="named",
        help="License type (default: %(default)s)",
    )
    parser.add_argument(
        "--start-date", help="License start date (YYYY-MM-DD, default: 2024-08-10)"
    )
    parser.add_argument(
        "--end-date",
        help="License end date (YYYY-MM-DD, default: 2034-08-01)",
    )

    args = parser.parse_args()

    args.apply = args.apply or args.oneshot

    # Validate date format if provided
    for date_arg in [args.start_date, args.end_date]:
        if date_arg:
            try:
                datetime.strptime(date_arg, "%Y-%m-%d")
            except ValueError:
                print(
                    f"Error: Invalid date format '{date_arg}'. Use YYYY-MM-DD format."
                )
                return 1

    # end date must not be before start date and must not be more than 10 years from start date
    if args.license or args.oneshot:
        start_dt = datetime.strptime(args.start_date or "2024-08-10", "%Y-%m-%d")
        end_dt = datetime.strptime(args.end_date or "2034-08-01", "%Y-%m-%d")

        if end_dt < start_dt:
            print("Error: End date must not be before start date.")
            return 1

        if (end_dt - start_dt).days >= 3650:
            print("Error: End date must not be more than 10 years from start date.")
            return 1

    success = True

    if args.patch or args.oneshot:
        success_count = patch_ida_files(args.apply)
        success = success_count > 0

        if success_count <= 0:
            print(
                "No files were patched. Ensure that you run this script from the IDA installation directory."
            )
            parser.print_help()
            return 1

    if args.license or args.oneshot:
        print("Generating license...")
        license_data = create_license(
            name=args.name,
            license_type=args.license_type,
            start_date=args.start_date,
            end_date=args.end_date,
        )

        success = generate_license_file(license_data)

    return 0 if success else 1


if __name__ == "__main__":
    exit(main())