# BioInformatics for Proteins and Peptides
Written and created by Cameron Ridderikhoff.
For Dr. Glen Ulrig, at the University of Alberta.

To use this set of functions:

## Section 00: Generating GeneSets
### This section is mostly for Glen, to generate the GeneSets folder and its contents.
### This section should only have to be used the first time this program is used.
1. Read the SetRank vignette, section 3.1.1 (this can be found by typing ">??SetRank" in the R console).
2. Download the GeneSets folder from GitHub, and put it inside "base" (see below).
3. "cd" into the GeneSets folder and open the "organisms" file.
4. Delete everything in this file, and create a single line:Arabidopsis thaliana
5. In the terminal, type the command "make" to generate the arabidopsis files.

## Section 0: Pre-setup
### This section is mostly for Glen, to ensure the R libaries are all installed.
### This section should only have to be used the first time this program is used.
There are two ways to install packages in R. One way is using the default ">install.packages("PackageName")" function included in R, and the second is ">source("http://bioconductor.org/biocLite.R")" followed by ">biocLite("PackageName")". The numbered commands should all work as listed, but if not, first try the default, then the second option if the first does not work. 
The following are commands to run IN THE CONSOLE OF RSTUDIO. The ">" key will be ommited for brevity, as well as the quotation marks around the commands.
1. install.packages("proteus")
2. install.packages("ggplot2")
3. install.packages("dplyr")
4. install.packages("pheatmap")
5. install.packages("tidyr")
6. install.packages("stringr")
7. source("http://bioconductor.org/biocLite.R")
8. biocLite("SetRank")
9. biocLite("biomaRt)


## Section 1: Setup
### For the program to run properly, you must ensure your files are organized correctly.
### Files should be organized as follows:
1. ALL R, Python and GeneSet files and folders MUST be in a folder called "base".
2. There MUST be a folder called "data" INSIDE of "base".
3. There MUST be the file "Phospho (STY)Sites.txt" INSIDE "data".
4. There MUST be the evidence file for the PHOSPHORYLATED peptides, called "evidence.txt" INSIDE "data".
5. There MUST be the protein groups file for the PROTEINS, called "proteinGroups.txt" INSIDE "data".
6. There may or may not be a folder called "outputs". If it does not already exist, it will be created for you.
7. Inside each R file "ProteinWorkflow.R", and "PeptideWorkflow.R", you must set your base directory. Details on how to do this are at the top of both files.

## SECTION 2: GeneSets
### Generate GeneSets, and ensure they are up-to-date.
1. "cd" into the directory "base" in your terminal.
2. "cd" into the "GeneSets" folder.
3. Type the command "make". This process is automated, and will make everything that GeneSets needs.
(Optional) If you need more species of PLANTS, you MUST add them to the "organisms" file BEFORE running the "make" command. You MUST also go into "ProteinWorkflow.R" and add a NEW line on line 30 AFTER "library(GeneSets.Arabidopsis.thaliana)", with the line reading "library(GeneSets.YOUR_NEW_ORGANISM)". You will then go to line 165 (line 164 in the unaltered file), and change "mart = useMart(biomart = "plants_mart",host="plants.ensembl.org", dataset = "athaliana_eg_gene")" to "mart = useMart(biomart = "plants_mart",host="plants.ensembl.org", dataset = "YOUR_PLANT's_DATASET")". From the SetRank vignette: Make sure there is only one name per line and that the lines do not contain any leading or trailing white space characters. Also, make sure that the names you are using correspond exactly to the official names used by the NCBI taxonomy database, as this is the reference used by the GeneSets package. Using the correct name is especially important when working with bacterial strains and substrains.

## Section 2: Protein Classification
1. "cd" into the directory "base" in your terminal.
2. Type the command "python3 run_protein_workflow.py".
3. Follow the prompts, and the workflow will run. This may take a while.
If it finishes and outputs ""Script passed with code: 0", you are done. 
If it finishes and outputs "Script failed with code: " and some number, there was an error running the project. Contact Glen if this happens, and tell him the error code and any other outputted information.

## Section 3: Peptide Classification.
1. "cd" into the directory "base" in your terminal.
2. Type the command "python3 run_peptide_workflow.py".
3. Follow the prompts, and the workflow will run. This may take a while.