# Import Vicon Nexus Data
***** Import Vicon Nexus Data in MatLab and Python ******

If you find this library helpful in your project, please consider mentioning us in your credits or sharing how you're using it. We'd love to hear your success stories! 😊

# How it works 
This simple function permits to import properly all data stored in a txt or csv file exported with Vicon Nexus.
It imports the data in different structs with the name saved in Nexus for each channel/marker:

- Frequencies (will contain up to 3 variables with the frequencies of Analog data, Marker and Model Outputs)
- Labels (of the analog, markers, and model outputs for using in a for/do while loop)
- Analog
- Markers (e.g. HEAD_Marker with 3 columns which correspond to X,Y,Z)
- Model Outputs

Tested and worked on both TXT and CSV exported from Vicon Nexus 2.6, 2.7, and 2.12 

BE CAREFUL about the outputs you export from Vicon Nexus as they can affect the locations of the references in the program

## How to Mention

You can credit my work by including the following text:

"The library used is publicly available on GitHub: [Import Vicon Data](https://github.com/PaulT95/Import_Vicon_Data/)."

## Share with me

If you have an interesting story or a cool project using my library, feel free to share it with me. I'd be delighted to hear what you've achieved with my contribution!

Thank you for choosing this library. Happy coding! 😄
