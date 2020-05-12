# BioInformatics for Peptides
Written and created by Cameron Ridderikhoff.
For Dr. Glen Ulrig, at the University of Alberta.

To use this set of functions:

## Section 1: Setup
### For the program to run properly, you must ensure your files are organized correctly.
### Files should be organized as follows:
1. ALL R, Python and GeneSet files and folders MUST be in a folder called "base".
2. There MUST be a folder called "data_ptm" INSIDE of "base".
3. There MUST be the evidence file for the PHOSPHORYLATED peptides, called "evidence.txt" INSIDE "data_ptm".
4. There may or may not be a folder called "outputs_ptm". If it does not already exist, it will be created for you.

## Section 2: Peptide Classification.
1. "cd" into the directory "base" in your terminal.
2. Type the command "python3 run_peptide_workflow.py".
3. Follow the prompts, and the workflow will run. This may take a while.