import subprocess
import create_metadata_file as cmf # import the create_metadata_file.py methods so that we can call it from this file
import remove_useless_peptides as rup


# Remove the peptides that have a threshold lower than what the user has selected.
# Gets peptide information from "Phospho (STY)Sites.txt" 
rup.remove_useless_peptides("data/Phospho (STY)Sites.txt")

# Create the metadata file, and get the arguments that we need to send into PeptideWorkflow.R
R_args = cmf.create_metadata_file("data_pep/")

# Use subprocess to run the ProteusWorkflow.R script 
return_code = subprocess.call("Rscript --vanilla -e 'source(\"PeptideWorkflow.R\")'" + R_args, shell=True)

if return_code != 0: 
    # if the return code is not 0, this means that the script has encountered an error, so print out the return code to allow the user to determine what happened
    print("Script failed with code: " + str(return_code))
else:
    # will always be 0 if the script passes.
    print("Script passed with code: " + str(return_code))
