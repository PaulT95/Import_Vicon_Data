# Import_Vicon_Data
This simple function permit to import properly all data stored in a txt file exported with Vicon Nexus
It imports the data in different structs with the name saved in Nexus for each channel/marker like:
- Frequencies
- Labels (of the analog,markers and model outputs for using in a for/do while cycle)
- Analog
- Markers (e.g. HEAD_Markers with 3 column which correspond to X,Y,Z)
- Model Outputs
- Force
