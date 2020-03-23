import string
import re # for regular expressions
# This function creates a metadata file that will be used by the Proteus R package.
# @input: N/A
# @output: R_args - a vector containing valuable information that the ProteusWorkflow.R script needs. 
#          It is of the form: [num_samples, control_condition, condition1, condition2, ..., conditionX]
def create_metadata_file():
    # Generate the file if it does not exist, or overwrite the data that is there already
    meta = open("proteus_data/practice_data_files/TP_XYZ/txt/meta.txt", 'w')
    # Proteus requires the first row to be exactly like this:
    # experiment   measure   sample   condition
    meta.write("experiment\tmeasure\tsample\tcondition\n")

    print("Press 'q' at any time to quit the program.")

    # Ask the user for the number of samples per group, and ensure it is a valid integer
    num_samples = input("Please enter the number of samples per group: ")
    while not re.match("^[0-9]*$", num_samples):
        if num_samples == 'q':
            exit()
        print("The number of samples must be an integer.")
        num_samples = input("Please enter the number of samples per group: ")

    # Ask the user for the names of all of the conditions. 
    # NOTE: It is up to the user to ensure accuracy in this step, as it is impossible for this program to
    # know if the condition name is correct, without outside knowledge.
    conditions = []
    while "e" not in conditions:
        cond = input("Please enter the name of one of the conditions, or press 'e' to exit: ")
        if cond == 'q':
            exit()
        conditions.append(cond)

    conditions.pop() #remove the "e" from conditions, so as to avoid adding it to the metadata file

    # NOTE: In all the cases I have seen, Glen uses an intensity measurement for MaxQuant. I do 
    # not know if this would ever change, but if it does, you must change this line to ask the user what 
    # the measurement should be.
    measure = "Intensity"

    # Get the name of the control condition from the user, and ensure that it is indeed one of the previously
    # given conditions.
    R_args = input("Please enter the name of the control condition: ")
    while R_args not in conditions:
        if (R_args == "q"):
            exit()
        print("The control must be one of the previously entered conditions.")
        R_args = input("Please enter the name of the control condition: ")
    
    # Write the required data to the metadata file. See the Proteus vignette as to what is required.
    R_args = " " + num_samples + " " + R_args
    for condition in conditions: # For each condition:
        for i in range(1, int(num_samples) + 1): # For each sample number
            experiment = condition + "_" + str(i) # experiment is of the form: Phos_1, or Phi_2, ect...
            sample = experiment # In the Proteus vignette, sample had the same value as experiment. I am unsure why. 
            
            # Write the line to the metadata file
            meta.write(experiment + "\t" + measure + "\t" + sample + "\t" + condition + "\n")
        # Add the condition to the R_args vector.
        R_args = R_args + " " + condition 

    # Close the file and return to the main function.
    meta.close()
    print("Metadata file successfully generated.")
    return R_args
