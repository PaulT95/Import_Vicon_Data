import pandas as pd

def vicon_read_file(file_name):
    # Read data
    ext = file_name.split(".")[-1].lower()

    if ext == "txt":
        delimiter = "\t"
    elif ext == "csv":
        delimiter = ","
    else:
        print("File format not supported!")
        return

    table_data = pd.read_csv(file_name, delimiter=delimiter, encoding="utf-8")
    data = table_data.values

    # Frequencies
    freq_analog = float(data[data[:, 0] == 'Devices', 1])
    freq_model_outputs = float(data[data[:, 0] == 'Model Outputs', 1])
    freq_markers = float(data[data[:, 0] == 'Trajectories', 1])

    frequencies = {
        'Analog': freq_analog,
        'ModelOutputs': freq_model_outputs,
        'Markers': freq_markers
    }

    # Reference names/values
    ref_dev = data[:, 0] == 'Devices'
    ref_m_out = data[:, 0] == 'Model Outputs'
    ref_mrk = data[:, 0] == 'Trajectories'

    ref_indices_dev = [idx for idx, val in enumerate(ref_dev) if val]
    ref_indices_m_out = [idx for idx, val in enumerate(ref_m_out) if val]
    ref_indices_mrk = [idx for idx, val in enumerate(ref_mrk) if val]

    # Analog Data and Labels
    analog_labels = data[ref_indices_dev[0] + 3, 2:]
    analog_labels = [label for label in analog_labels if isinstance(label, str)]

    # Process labels with multiple Fx (force plates)
    pos = [idx for idx, label in enumerate(analog_labels) if 'Fx' in label]
    if len(pos) > 1:
        for n_plat in range(len(pos)):
            sub_string = f'_{n_plat + 1}'
            if n_plat != len(pos) - 1:
                analog_labels[pos[n_plat]:pos[n_plat + 1]] = [label + sub_string for label in analog_labels[pos[n_plat]:pos[n_plat + 1]]]
            else:
                analog_labels[pos[n_plat]:] = [label + sub_string for label in analog_labels[pos[n_plat]:]]

    analog_data = {}
    for k, label in enumerate(analog_labels):
        if not label.isidentifier():
            label = f'Var_{k}'

        if len(ref_indices_m_out) > 0:
            analog_data[label] = data[ref_indices_dev[0] + 5:ref_indices_m_out[0], k + 2].astype(float)
        elif len(ref_indices_mrk) > 0:
            analog_data[label] = data[ref_indices_dev[0] + 5:ref_indices_mrk[0], k + 2].astype(float)
        else:
            analog_data[label] = data[ref_indices_dev[0] + 5:-1, k + 2].astype(float)

    # Markers data and labels
    markers_labels = data[ref_indices_mrk[0] + 2, :]
    markers_labels = [label for label in markers_labels if isinstance(label, str)]
    markers_data = {}

    for k, label in enumerate(markers_labels):
        if not label.isidentifier():
            label = f'Var_{k}'

        markers_data[label] = data[ref_indices_mrk[0] + 5:, k:(k + 3)].astype(float)

    return frequencies, analog_data, markers_data

# Example usage
file_path = 'path/to/your/VICON.txt'  # Replace with your file path
frequencies, analog_data, markers_data = vicon_read_file(file_path)
print(f"Frequencies: {frequencies}")
print(f"Analog Data: {analog_data}")
print(f"Markers Data: {markers_data}")
