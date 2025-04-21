import subprocess


def send_notification(title: str, message: str, doPrint=True):
    """
    Sends a desktop notification using the notify-send command.

    :param title: Title of the notification
    :param message: Body of the notification
    """
    try:
        # Call the 'notify-send' command to send the notification
        subprocess.run(["notify-send", "-t", "5000", title, message], check=True)
        if doPrint:
            print(f"Notification sent: {title} - {message}")
    except subprocess.CalledProcessError as e:
        if doPrint:
            print(f"Error sending notification: {e}")


def write_to_file(title: str, message: str):
    with open("/home/francois/.config/nvim_logs/remote_logs.log", "a") as f:
        print(f"======[{title}]======\n", file=f)
        print(message, file=f)
        print("=========END===========\n", file=f)
