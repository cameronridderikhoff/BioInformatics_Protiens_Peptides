# BioInformatics for Proteins
Written and created by Cameron Ridderikhoff.
For Dr. Glen Ulrig, at the University of Alberta.

To use this set of functions:

## Section 1: Setup
### For the program to run properly, you must ensure your files are organized correctly.
### Files should be organized as follows:
1. ALL R, Python and GeneSet files and folders MUST be in a folder called "base".
2. There MUST be a folder called "data_prot" INSIDE of "base".
3. There MUST be the protein groups file for the PROTEINS, called "proteinGroups.txt" INSIDE "data_prot".
4. There may or may not be a folder called "outputs_prot". If it does not already exist, it will be created for you.
5. You should make a background for quantitative peptide analysis, and insert it into R. Insert after line 172 of ProteinWorkflow.R.

## SECTION 2: GeneSets
### Generate GeneSets, and ensure they are up-to-date.
1. "cd" into the directory "base" in your terminal.
2. "cd" into the "GeneSets" folder.
3. Type the command "make". This process is automated, and will make everything that GeneSets needs.
(Optional) If you need more species of PLANTS, you MUST add them to the "organisms" file BEFORE running the "make" command. You MUST also go into "ProteinWorkflow.R" and add a NEW line on line 30 AFTER "library(GeneSets.Arabidopsis.thaliana)", with the line reading "library(GeneSets.YOUR_NEW_ORGANISM)". You will then go to line 165 (line 164 in the unaltered file), and change "mart = useMart(biomart = "plants_mart",host="plants.ensembl.org", dataset = "athaliana_eg_gene")" to "mart = useMart(biomart = "plants_mart",host="plants.ensembl.org", dataset = "YOUR_PLANT's_DATASET")". From the SetRank vignette: Make sure there is only one name per line and that the lines do not contain any leading or trailing white space characters. Also, make sure that the names you are using correspond exactly to the official names used by the NCBI taxonomy database, as this is the reference used by the GeneSets package. Using the correct name is especially important when working with bacterial strains and substrains.

## Section 3: Protein Classification
1. "cd" into the directory "base" in your terminal.
2. Type the command "python3 run_protein_workflow.py".
3. Follow the prompts, and the workflow will run. This may take a while.
If it finishes and outputs ""Script passed with code: 0", you are done. 
If it finishes and outputs "Script failed with code: " and some number, there was an error running the project. Contact Glen if this happens, and tell him the error code and any other outputted information.