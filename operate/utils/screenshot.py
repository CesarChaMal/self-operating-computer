import os
import platform
import subprocess

from PIL import Image, ImageDraw, ImageGrab

# Only import pyautogui and Xlib if GUI is available
GUI_AVAILABLE = bool(os.environ.get('DISPLAY'))

if GUI_AVAILABLE:
    import pyautogui
    import Xlib.display
    import Xlib.X
    import Xlib.Xutil

def capture_screen_with_cursor(file_path):
    user_platform = platform.system()

    if not GUI_AVAILABLE:
        print("⚠️ GUI not available. Skipping screenshot capture.")
        return

    if user_platform == "Windows":
        screenshot = pyautogui.screenshot()
        screenshot.save(file_path)
    elif user_platform == "Linux":
        screen = Xlib.display.Display().screen()
        size = screen.width_in_pixels, screen.height_in_pixels
        screenshot = ImageGrab.grab(bbox=(0, 0, size[0], size[1]))
        screenshot.save(file_path)
    elif user_platform == "Darwin":  # MacOS
        subprocess.run(["screencapture", "-C", file_path])
    else:
        print(f"⚠️ Platform {user_platform} not supported for screenshots.")

def compress_screenshot(raw_screenshot_filename, screenshot_filename):
    try:
        with Image.open(raw_screenshot_filename) as img:
            if img.mode in ('RGBA', 'LA') or (img.mode == 'P' and 'transparency' in img.info):
                background = Image.new('RGB', img.size, (255, 255, 255))
                background.paste(img, mask=img.split()[3])
                background.save(screenshot_filename, 'JPEG', quality=85)
            else:
                img.convert('RGB').save(screenshot_filename, 'JPEG', quality=85)
    except FileNotFoundError:
        print(f"⚠️ Warning: Screenshot {raw_screenshot_filename} not found, skipping compression.")
