#Author: Paolo Tecchio
#email: paolo.tecchio@rub.de


#import libraries
import pandas as pd
import numpy as np

def read_vicon_file(file_name):
    ext = file_name.split(".")[-1].lower()

    if ext == "txt":
        delimiter = "\t"
    elif ext == "csv":
        delimiter = ","
    else:
        print("File format not supported!")
        return

    table_data = pd.read_csv(file_name, delimiter=delimiter, encoding="utf-8", header=None)  # Read data without header
    data = table_data.values

    # Extract frequencies and reference indices
    freq_labels = ['Devices', 'Model Outputs', 'Trajectories']
    frequencies = {}
    ref_indices = {}

    for label in freq_labels:
        label_rows = [idx for idx, val in enumerate(data[:, 0]) if val == label]
        print(f"Value: {label_rows}")

        if label_rows:
            frequencies[label] = float(data[label_rows[0] + 1, 0])
            ref_indices[label] = label_rows

    # Analog data extraction
    analog_labels = data[ref_indices['Devices'][0] + 3, 2:]
    analog_labels = [label for label in analog_labels if isinstance(label, str)]

    # Count occurrences of each label as more platforms can be present
    label_counts = {}
    unique_analog_labels = []

    for label in analog_labels:
        if label in label_counts:
            label_counts[label] += 1
            unique_label = f"{label}_{label_counts[label]}"
        else:
            label_counts[label] = 1
            unique_label = label  # f"{label}_{label_counts[label]}"
        unique_analog_labels.append(unique_label)

    analog_labels = unique_analog_labels
    del label_counts, unique_analog_labels  # clear vars

    # Markers data extraction
    markers_labels = data[ref_indices['Trajectories'][0] + 2, :]
    markers_labels = [label for label in markers_labels if isinstance(label, str)]
    split_labels_markers = [label.split(':') for label in markers_labels]

    # Remove the first element/subject name from each sublist
    cleaned_labels_markers = [sublist[1] for sublist in split_labels_markers]
    markers_labels = cleaned_labels_markers

    # Model Outputs data extraction
    model_outputs_labels = data[ref_indices['Model Outputs'][0] + 2, :]
    test = model_outputs_labels.astype(str)  # Convert everything as a string
    position = [idx for idx, label in enumerate(test) if label.lower() != 'nan']
    del test

    # Filter out non-string labels
    model_outputs_labels = [label for label in model_outputs_labels if isinstance(label, str)]
    split_labels_markers = [label.split(':') for label in model_outputs_labels]

    # Remove the first element/subject name from each sublist
    cleaned_labels_markers = [sublist[1] for sublist in split_labels_markers]
    model_outputs_labels = cleaned_labels_markers

    del split_labels_markers  # delete var

    ## Analog data processing
    analog_data = {}
    if 'Devices' in ref_indices:
        analog_start = ref_indices['Devices'][0] + 5
        if 'Model Outputs' in ref_indices:
            analog_end = ref_indices['Model Outputs'][0] - 1
        elif 'Trajectories' in ref_indices:
            analog_end = ref_indices['Trajectories'][0] - 1
        else:
            analog_end = len(data) - 1

        for idx, label in enumerate(analog_labels):
            analog_data[label] = data[analog_start:analog_end, idx + 2].astype(float)

    ## Markers data processing
    markers_data = {}
    if 'Trajectories' in ref_indices:
        markers_start = ref_indices['Trajectories'][0] + 5
        if 'Model Outputs' in ref_indices and ref_indices['Model Outputs'][0] > ref_indices['Trajectories'][0]:
            markers_end = ref_indices['Model Outputs'][0] - 1
        else:
            markers_end = len(data) #-1 not, because in a range it does not count the last element included

        for label in markers_labels:
            markers_data[label] = data[markers_start:markers_end,
                                  markers_labels.index(label) + 2 : markers_labels.index(label) + 5].astype(float)

    ## Model output data processing

    model_outputs_data = {}

    if 'Model Outputs' in ref_indices:
        model_outputs_start = ref_indices['Model Outputs'][0] + 5
        if 'Trajectories' in ref_indices and ref_indices['Model Outputs'][0] < ref_indices['Trajectories'][0]:
            model_outputs_end = ref_indices['Trajectories'][0] - 1  # Adjusted to -2
        else:
            model_outputs_end = len(data) #- 1, see above

        for label, pos in zip(model_outputs_labels, position):
            index = position.index(pos)  # Get the index of the current position
            if index == len(position) - 1:
                model_output_data = data[model_outputs_start:model_outputs_end, pos:].astype(float)
            else:
                next_pos = position[index + 1]
                model_output_data = data[model_outputs_start:model_outputs_end, pos:next_pos].astype(float)

            model_outputs_data[label] = model_output_data


    # return the stuff
    labels = {'Analog': analog_labels,
              'ModelOutputs': model_outputs_labels,
              'Markers': markers_labels
              }

    return frequencies, analog_data, markers_data, model_outputs_data, labels
