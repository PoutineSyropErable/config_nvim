import subprocess
from typing import Callable, List
import re

from send_notification import send_notification, write_to_file


def return_only_ascii(string):
    return "".join([x for x in string if x.isascii()])


def is_visible(string_start: str) -> bool:
    # Loop through the string and check if any character is printable

    string = return_only_ascii(string_start)

    if not string.isascii():
        return False

    if not string.isprintable():
        return False

    exclude_list = ["[", "]", "\\", "?"]

    for char in string:

        if not char.isascii():
            continue

        if not char.isprintable():
            continue

        if char.isspace():
            continue

        ascii_code = ord(char)

        # Check if it's an ASCII printable character or a valid Unicode character
        if char in exclude_list:
            continue

        # ASCII printable characters are from 32 (space) to 126 (~)
        if 32 <= ascii_code <= 126:
            write_to_file(
                "python debug",
                f"String repr: {repr(string)}\nString_nice: {str(string)}\nchar: {char}, repr: {repr(char)}, asci code:{ascii_code}",
            )
            return True

        # Check if it's a valid Unicode character (Unicode non-control characters)
        # In the Unicode specification, printable characters generally start at U+0020 and can go much higher
        # excluding control characters (0x00-0x1F, 0x7F, etc.)
        if (0x20 <= ascii_code < 0x110000) and (ascii_code not in range(0x00, 0x20) and ascii_code != 0x7F):
            write_to_file("python debug", f"String: {string}\nchar: {char}, repr: {repr(char)}, asci code:{ascii_code}")
            return True

    send_notification("python debug", "returned false", False)
    return False  # If no printable character is found, return False


def clean_output(output: str) -> str:
    # This regex removes all escape sequences

    if not is_visible(output):
        return ""

    cleaned = re.sub(r"\x1b\[[0-9;]*[a-zA-Z]", "", output)

    # Remove any extra control characters or special characters that may still be present
    cleaned = re.sub(r"[\x00-\x1F\x7F]", "", cleaned)  # This will remove control characters

    cleaned_stripped = cleaned.strip()  # Removing any leading/trailing whitespaces
    # Strip leading/trailing whitespaces and split by new lines
    if not is_visible(cleaned_stripped):
        return ""

    return cleaned_stripped


class StdPrinter:

    def std_print(self, result: subprocess.CompletedProcess[bytes]):

        if result.stdout:
            decoded_std_out = result.stdout.decode("ascii", errors="ignore")
            cleaned_std_out = clean_output(decoded_std_out)
            if cleaned_std_out:
                send_notification("a", str(len(cleaned_std_out)), False)
                self.printf(f"=======[stdout]:========\n[{cleaned_std_out}]\n")

        if result.stderr:
            decoded_std_err = result.stderr.decode("ascii", errors="ignore")
            cleaned_std_err = clean_output(decoded_std_err)
            if cleaned_std_err:
                self.printf(f"=======[stderr]:========\n[{cleaned_std_err}]")

    def set_printf(self, printf: Callable[[str], None]):
        self.printf = printf

    @staticmethod
    def print_result(printf: Callable[[str], None], result: subprocess.CompletedProcess[bytes]):
        stdPrinter = StdPrinter()
        stdPrinter.set_printf(printf)
        stdPrinter.std_print(result)


if __name__ == "__main__":

    # Testing the function
    print(is_visible("Hello, World!"))  # Should return True (all printable)
    print(is_visible("Hello\x01World!"))  # Should return True (contains visible characters)
    print(is_visible("Hello\x00World!"))  # Should return True (contains visible characters)
    print(is_visible("⛔"))  # Should return True (Unicode character)
    print(is_visible("💡"))  # Should return True (Unicode character)
    print(is_visible(""))  # Should return False (empty string)
    print(is_visible("\x00"))  # Should return False (empty string)
    print(is_visible("$"))  # Should return False (empty string)
    print(is_visible("="))  # Should return False (empty string)
    print(is_visible("-"))  # Should return False (empty string)
