# To see some information pertaining to the following code,
# Run the command:
# >vignette("proteus", package="proteus")
# The following code is from the "Quick Start" Option, and is commented by Cameron Ridderikhoff, 
# with information from the vignette itself.

# libary(x) tells R what library, or set of functions, it needs to use. Here we are using proteus, so we must include it.
library(proteus)

# "read" the evidence.txt file from MaxQuant (here, "read" simply means bring it into R)
#evidenceFile <- system.file("extdata", "evidence.txt.gz", package="proteusLabelFree")
# turn the evidenceFile into something that proteus can use, by calling the readEvidenceFile function
#evi <- readEvidenceFile(evidenceFile)

# read the metadata file that has been created **BY THE USER**
#metadataFile <- system.file("extdata", "metadata.txt", package="proteusLabelFree")
# turn the metadataFile into something that proteus can use
#meta2 <- read.delim(metadataFile, header=TRUE, sep="\t")

# call the makePeptideTable function to create a peptide data object from the evidence and metadata
#pepdat <- makePeptideTable(evi, meta)

# Create a protein dara object from the peptide data object. "For simplicity, we assign peptides to proteins based on the Leading Razor Protein."
#prodat <- makeProteinTable(pepdat)

# Normalize the protein data to account for variation of intensity between samples. The default normalization is to the median.
#prodat.med <- normalizeData(prodat)

# NOTE: This is to be done INSTEAD of the above, if the proteinGroups file is available.
# (Section 5.5 Reading MaxQuant’s protein groups file)
# Read the proteinGroups file from MaxQuant directly
#proteinGroupsFile <- system.file("extdata", "proteinGroups.txt.gz", package="proteusLabelFree") # this line will pull data from the vignette
# turn the proteinGroupsFile into something that proteus can use
#prot.MQ <- readProteinGroups(proteinGroupsFile, meta2)

# read the metadata file
meta <- read.delim("/Users/cameronridderikhoff/Documents/CMPUT399/proteus_data/practice_data_files/TP_XYZ/txt/meta.txt", header = TRUE, sep = "\t", dec = ".")
# NOTE: This is to be done INSTEAD of the above, if the proteinGroups file is available.
# (Section 5.5 Reading MaxQuant’s protein groups file)
# Read the proteinGroups file from MaxQuant directly, and immediately turn it into something useful for Proteus
prot.MQ <- readProteinGroups("/Users/cameronridderikhoff/Documents/CMPUT399/proteus_data/practice_data_files/TP_XYZ/txt/proteinGroups.txt", meta)


# limma package link: http://bioconductor.org/packages/release/bioc/html/limma.html
# Before limma is called, intensity data are transformed using log2. To change this to log10, replace with
# res <- limmaDE(prodat.med, transform.fun=log10)
# Perform differential expression on the normalized protein data
# This function can only be used on 2 conditions at a time. 
res <- limmaDE(prot.MQ, conditions = c("Phos", "NO_Phos"))

# plot the results using a live, alterable Volcano Plot:
# We strongly recommend to build protein annotations before running live functions.
plotVolcano_live(prot.MQ, res)



