# To see some information pertaining to the following code,
# Run the command:
# >vignette("proteus", package="proteus")
# The following code is from the "Quick Start" Option, and is commented by Cameron Ridderikhoff, 
# with information from the vignette itself.

# libary(x) tells R what library, or set of functions, it needs to use. Here we are using proteus, so we must include it.
library(proteus)

# read the metadata file
meta <- read.delim("/Users/cameronridderikhoff/Documents/CMPUT399/BioInformatics_Protiens_Peptides/proteus_data/practice_data_files/TP_XYZ/txt/meta.txt", header = TRUE, sep = "\t", dec = ".")

# (Section 5.5 Reading MaxQuant’s protein groups file)
# Read the proteinGroups file from MaxQuant directly, and immediately turn it into something useful for Proteus
prot.MQ <- readProteinGroups("/Users/cameronridderikhoff/Documents/CMPUT399/BioInformatics_Protiens_Peptides/proteus_data/practice_data_files/TP_XYZ/txt/proteinGroups.txt", meta)


#DO LOG 2 then plot histogram 
tab <- log2(prot.MQ$tab)
plotSampleDistributions(prot.MQ, method = "dist", log.base = 2) #plots histogram plots of the (log2 value? frequency?) of each sample
plotSampleDistributions(prot.MQ, log.base = 2) #plot box plots of the log2 value of each sample


# limma package link: http://bioconductor.org/packages/release/bioc/html/limma.html
# Before limma is called, intensity data are transformed using log2. To change this to log10, replace with
# res <- limmaDE(prodat.med, transform.fun=log10)
# Perform differential expression on the normalized protein data
# This function can only be used on 2 conditions at a time. 
results_Phos <- limmaDE(prot.MQ, conditions = c("NO_Phos", "Phos"))
results_Phi <- limmaDE(prot.MQ, conditions = c("NO_Phos", "Phi"))

# plot the results using a live, alterable Volcano Plot:
# We strongly recommend to build protein annotations before running live functions.
plotVolcano_live(prot.MQ, results_Phos)
plotVolcano_live(prot.MQ, results_Phi)

#Plot a line with adjusted p-value threshold of 0.05 
#Add a column with regular p-value as well (need to alter the limmaDE function from Proteus)
plotPdist(results_Phi)
plotPdist(results_Phos)
