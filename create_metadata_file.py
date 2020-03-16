import string
import subprocess
import re
def create_metadata_file():
    meta = open("proteus_data/practice_data_files/TP_XYZ/txt/meta.txt", 'w')
    meta.write("experiment\tmeasure\tsample\tcondition\n")

    print("Press 'q' at any time to quit the program.")
    num_samples = input("Please enter the number of samples per group: ")
    while not re.match("^[0-9]*$", num_samples):
        if num_samples == 'q':
            exit()
        print("The number of samples must be an integer.")
        num_samples = input("Please enter the number of samples per group: ")

    conditions = []
    while "e" not in conditions:
        cond = input("Please enter the name of one of the conditions, or press 'e' to exit: ")
        if cond == 'q':
            exit()
        conditions.append(cond)

    conditions.pop() #remove the "e" from conditions, so as to avoid adding it to the metadata file

    measure = "Intensity"
    R_args = input("Please enter the name of the control condition: ")
    while R_args not in conditions:
        print("The control must be one of the previously entered conditions.")
        R_args = input("Please enter the name of the control condition: ")
    R_args = " " + R_args + " "
    for condition in conditions:
        for i in range(1, int(num_samples) + 1):
            experiment = condition + "_" + str(i)
            sample = experiment
            meta.write(experiment + "\t" + measure + "\t" + sample + "\t" + condition + "\n")
        R_args = R_args + " " + condition 

    meta.close()
    print("Metadata file successfully generated.")
    return R_args + " " + num_samples
