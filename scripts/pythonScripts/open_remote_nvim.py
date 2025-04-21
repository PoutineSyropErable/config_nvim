#!/usr/bin/env python

import os
import subprocess
import threading
from queue import Queue
import sys
import argparse
from typing import List, Callable
from time import sleep


from root_utils import FsDirPathStr, FsFilePathStr, get_session_file

from send_to_nvim import DEFAULT_RSM, send_to_nvim
from send_notification import send_notification
from helper import StdPrinter, clean_output
from open_helper import delay_action, attach_lsp_to_all_buffers


def open_nvim(files: List[str], remote_session_name: str = DEFAULT_RSM):
    """
    This function opens Neovim with the session and sends files after a delay.
    """
    # Prepare the command to run Neovim in the foreground

    real_files = [os.path.realpath(file) for file in files]
    socket: FsFilePathStr = f"/tmp/nvim_session_socket_{remote_session_name}"

    command = [
        "nvim",
        "--listen",
        socket,
        "--cmd",
        f"autocmd VimEnter * NvimPossessionLoadOrCreate {remote_session_name}",
    ]

    # Start Neovim (blocking, but it will allow other threads to run)
    print(f"Neovim started with socket: /tmp/nvim_session_socket_{remote_session_name}")

    # Run Neovim (non-blocking)

    send_files_output_queue: Queue[str] = Queue()
    attach_lsps_output_queue: Queue[str] = Queue()
    if files:
        delay_action(0.5, send_to_nvim, files, remote_session_name, False, send_files_output_queue)
    delay_action(1, attach_lsp_to_all_buffers, socket, False, attach_lsps_output_queue)
    neovim_process = subprocess.run(command)

    # Wait for Neovim to finish (this will block the main thread until Neovim exits)

    # Optional: Retrieve output from the queue after Neovim finishes
    while not send_files_output_queue.empty():
        print(send_files_output_queue.get())

    while not attach_lsps_output_queue.empty():
        print(attach_lsps_output_queue.get())

    return 0


if __name__ == "__main__":
    # Create the parser
    parser = argparse.ArgumentParser(
        description="Open Neovim with session management.", formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    # This will include default values in the help message)

    # Add the --name argument for specifying the session name
    parser.add_argument("--name", type=str, default=DEFAULT_RSM, help="Name of the session (default: 'default')")

    # Add a positional argument for files (accepts multiple files)
    parser.add_argument("files", nargs="*", help="Files to open in Neovim.")

    # Parse arguments
    args = parser.parse_args()

    # If no arguments are passed, print the usage
    if len(sys.argv) == 1:
        print("No files provided. Opening Neovim with default session... And showing help message in case")
        parser.print_help()

    # Call the open_nvim function with parsed arguments
    ret = open_nvim(remote_session_name=args.name, files=args.files)
    exit(ret)
