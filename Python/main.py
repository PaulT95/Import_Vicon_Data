import tkinter as tk
from tkinter import filedialog
import matplotlib.pyplot as plt
from Vicon_Read_File import read_vicon_file

#import pandas as pd

# Select File
root = tk.Tk()
root.withdraw()

file_path = filedialog.askopenfilename()

# Example usage
frequencies, analog_data, markers_data, model_outputs_data, labels = read_vicon_file(file_path)
print(f"Frequencies: {frequencies}")
print(f"Analog Data: {analog_data}")
print(f"Markers Data: {markers_data}")
print(f"Model Outputs Data: {model_outputs_data}")
print(f"Labels: {labels}")
