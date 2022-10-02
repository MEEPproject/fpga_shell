import tkinter as tk
import time
from PIL import Image, ImageTk

print ('OLAKASE')
time.sleep(1.5)    # Pause 5.5 seconds

# Root is the tk (window) object
root = tk.Tk()
print ('OLAKASE')
time.sleep(1.5)    # Pause 5.5 seconds

canvas = tk.Canvas(root, width=1200, height=600)
canvas.grid(columnspan=3)
print ('OLAKASE')
time.sleep(1.5)    # Pause 5.5 seconds

logo = Image.open('BSC-Logo.png')
logo = ImageTk.PhotoImage(logo)
print ('OLAKASE')
time.sleep(1.5)    # Pause 5.5 seconds

logo_label = tk.Label(image=logo)
logo_label.image = logo
logo_label.grid(column=1, row=0)

instruction = tk.Label(root, text="Select the Clock source for HBM channel 1", font="Raleway")
instruction.grid(columnspan=3, column=0, row=1)

root.mainloop()