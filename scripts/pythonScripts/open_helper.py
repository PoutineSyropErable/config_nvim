#!/usr/bin/env python

import subprocess
import threading
from queue import Queue
from typing import List, Callable
from time import sleep


from helper import StdPrinter, clean_output


def attach_lsp_to_all_buffers(socket, printNotQueue=False, output_queue: Queue[str] = Queue()) -> None:
    """Function to attach all LSPs to all buffers."""

    def printf(message: str):
        message = clean_output(message)
        if printNotQueue:
            print(message)
        else:
            output_queue.put(message)

    printf(f"Attaching all LSPs to buffers in session with socket: {socket}")

    command = [
        "nvim",
        "--server",
        socket,
        "--remote-send",
        ":AttachAllLSPs<CR>",
    ]

    try:
        result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        # Put the captured output in the queue (ensure it's converted to strings if needed)
        StdPrinter.print_result(printf, result)

        # Check the process return code
        if result.returncode == 0:
            printf(f"Successfully attached all LSPs to buffers with socket: {socket}")
        else:
            printf(f"Error running Neovim: {result.returncode}")

    except subprocess.CalledProcessError as e:
        if printNotQueue:
            printf(f"Error running Neovim: {e}")

    return


def delay_action(delay: float, action: Callable, *args):
    """
    Decorator to delay the execution of a function.

    :param delay: Delay in seconds before calling the function
    :param action: Function to be called after the delay
    :param *args: Arguments to pass to the function
    """

    def wrapper():
        sleep(delay)  # Wait for the specified delay
        action(*args)  # Call the original action function with arguments

    # Start a thread to execute the action after the delay
    thread = threading.Thread(target=wrapper)
    thread.start()
