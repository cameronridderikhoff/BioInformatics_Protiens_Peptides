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

## Section 1: Windows vs. Mac vs. Linux
If you are performing your analysis on a Windows machine, there are a couple of steps you have to follow to convert this code-base into something that will be compatable with Windows. If you are on a Mac, you shouldn't have to do any other steps. If you are on a Linux machine then you may have to set up environment variables for R (step 1 below), but this program has not been tested on a Linux machine, so there may be further issues.
1. You must create an environment variable for Rscript, to do this in Windows, press the Windows button, then type "env" and click on "Edit the system environment variables", click on "Environment Variables...", then, under System variables, find "Path" or "PATH", and click "Edit...". Then add the path that Rscript.exe is found in, usually "C:\Program Files\R\R-3.XX\bin\i386". Click Ok, Click Ok, Click Ok. See http://softwaresaved.github.io/distance-consultancy/develop/SetUpDevelopmentR.html for more details.
2. You must change line 10 of run_protein_workflow.py from:
return_code = subprocess.call("Rscript --vanilla -e 'source(\"ProteinWorkflow.R\")'" + R_args, shell=True)
to
return_code = subprocess.call("Rscript ProteinWorkflow.R" + R_args, shell=True)
3. You must change line 14 of run_peptide_workflow.py from: 
return_code = subprocess.call("Rscript --vanilla -e 'source(\"PeptideWorkflow.R\")'" + R_args, shell=True)
to
return_code = subprocess.call("Rscript PeptideWorkflow.R" + R_args, shell=True)

## Next Steps:
If you are doing PTM analysis, open PTM_README.md

If you are doing proteome analysis, open Prot_README.md
