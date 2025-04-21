#!/usr/bin/env python

import subprocess
import sys
import argparse
import os
import glob
from typing import Callable, List
from time import sleep
from queue import Queue
import re

from send_notification import send_notification
from root_utils import FsFilePathStr, FsDirPathStr
from helper import StdPrinter, clean_output

DEFAULT_RSM = "default"  # Default session name


def send_to_nvim(
    files: List[FsFilePathStr],
    remote_session_name: str = DEFAULT_RSM,
    printNotQueue=True,
    output_queue: Queue[str] = Queue(),
):

    def printf(message: str):
        message = clean_output(message)
        if printNotQueue:
            print(message)
        else:
            output_queue.put(message)

    # Specify the socket location for the Neovim session
    socket = f"/tmp/nvim_session_socket_{remote_session_name}"

    # If no files were provided (even after expanding wildcards), print an error
    if not files:
        printf("No valid files provided. Please provide at least one file.")
        return 1

    real_files = [os.path.realpath(file) for file in files]
    # Prepare the command to run Neovim
    commands = []
    for real_file in real_files:
        commands.append(["nvim", "--server", socket, "--remote-send", f":e {real_file}<CR>"])

    try:
        for command, file in zip(commands, files):
            # Run the command to open the first file
            result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            printf(f"Sent {file} to Neovim instance at socket: {socket}")

            StdPrinter.print_result(printf, result)

    except subprocess.CalledProcessError as e:
        printf(f"Error sending files to Neovim: {e}")
        return 1

    return 0


def expand_files(files: List[str]) -> List[FsFilePathStr]:
    expanded_files = []
    for file in files:
        # If the file pattern contains wildcards, expand it
        expanded_files.extend(glob.glob(file))
    return expanded_files


if __name__ == "__main__":
    # Create the parser
    parser = argparse.ArgumentParser(description="Send files to a running Neovim instance.")

    # Add arguments for file and remote session name
    parser.add_argument("files", nargs="*", help="Files to send to Neovim. Supports wildcards (e.g., '*.txt').")
    parser.add_argument("--name", type=str, default=DEFAULT_RSM, help="The name of the Neovim session (default: 'default').")

    # Parse arguments
    args = parser.parse_args()

    # Expand file patterns if they contain wildcards
    files_to_send: List[FsFilePathStr] = expand_files(args.files)

    # If no files were given, show the help message and exit
    if not files_to_send:
        parser.print_help()
        sys.exit(1)

    # Call the send_to_nvim function with parsed arguments
    ret = send_to_nvim(remote_session_name=args.name, files=files_to_send)
    exit(ret)
