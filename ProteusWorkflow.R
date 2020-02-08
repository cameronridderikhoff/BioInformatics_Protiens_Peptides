# To see some information pertaining to the following code,
# Run the command:
# >vignette("proteus", package="proteus")
# The following code is from the "Quick Start" Option, and is commented by Cameron Ridderikhoff, 
# with information from the vignette itself.

#SECTION: Imports
# libary(x) tells R what library, or set of functions, it needs to use. Here we are using proteus, so we must include it.
library(proteus)
#import ggplot and cowplot for scatterplots
library(ggplot2)
library(cowplot)

#SECTION: Read input data
# read the metadata file
meta <- read.delim("/Users/cameronridderikhoff/Documents/CMPUT399/BioInformatics_Protiens_Peptides/proteus_data/practice_data_files/TP_XYZ/txt/meta.txt", header = TRUE, sep = "\t", dec = ".")

# (Section 5.5 Reading MaxQuant’s protein groups file)
# Read the proteinGroups file from MaxQuant directly, and immediately turn it into something useful for Proteus
prot.MQ <- readProteinGroups("/Users/cameronridderikhoff/Documents/CMPUT399/BioInformatics_Protiens_Peptides/proteus_data/practice_data_files/TP_XYZ/txt/proteinGroups.txt", meta)


#SECTION: Plot graphs of data

# Plot histogram and boxplot of log2 transformed data 
plotSampleDistributions(prot.MQ, method = "dist", log.base = 2) #plots histogram plots of the intensities/ratios of each sample
plotSampleDistributions(prot.MQ, log.base = 2) #plots box plots of the intensities/ratios of each sample

#perform log2 transformation on the data so we acn do scatterplots
dat <- data.frame(log2(prot.MQ$tab))

#plot scatterplots of NO_Phos
NP1_NP2 <- ggplot(dat, aes(pull(dat, 1), pull(dat, 2))) + geom_point()
NP1_NP3 <- ggplot(dat, aes(pull(dat, 1), pull(dat, 3))) + geom_point()
NP1_NP4 <- ggplot(dat, aes(pull(dat, 1), pull(dat, 4))) + geom_point()
NP2_NP3 <- ggplot(dat, aes(pull(dat, 2), pull(dat, 3))) + geom_point()
NP2_NP4 <- ggplot(dat, aes(pull(dat, 2), pull(dat, 4))) + geom_point()
NP3_NP4 <- ggplot(dat, aes(pull(dat, 3), pull(dat, 4))) + geom_point()
plot.new()
plot_grid(
  P1_P2, P1_P3, P1_P4, P2_P3, P2_P4, P3_P4,
  labels = c("NO_Phos1 vs NO_Phos2", "NO_Phos1 vs NO_Phos3", "NO_Phos1 vs NO_Phos4",
             "NO_Phos2 vs NO_Phos3", "NO_Phos2 vs NO_Phos4", "NO_Phos3 vs NO_Phos4"),
  align = "hv"
)

#plot scatterplots of Phos
P1_P2 <- ggplot(dat, aes(pull(dat, 5), pull(dat, 6))) + geom_point()
P1_P3 <- ggplot(dat, aes(pull(dat, 5), pull(dat, 7))) + geom_point()
P1_P4 <- ggplot(dat, aes(pull(dat, 5), pull(dat, 8))) + geom_point()
P2_P3 <- ggplot(dat, aes(pull(dat, 6), pull(dat, 7))) + geom_point()
P2_P4 <- ggplot(dat, aes(pull(dat, 6), pull(dat, 8))) + geom_point()
P3_P4 <- ggplot(dat, aes(pull(dat, 7), pull(dat, 8))) + geom_point()
plot.new()
plot_grid(
  P1_P2, P1_P3, P1_P4, P2_P3, P2_P4, P3_P4,
  labels = c("Phos1 vs Phos2", "Phos1 vs Phos3", "Phos1 vs Phos4",
             "Phos2 vs Phos3", "Phos2 vs Phos4", "Phos3 vs Phos4"),
  align = "hv"
)

#plot scatterplots of Phi
Pi1_Pi2 <- ggplot(dat, aes(pull(dat, 9), pull(dat, 10))) + geom_point()
Pi1_Pi3 <- ggplot(dat, aes(pull(dat, 9), pull(dat, 11))) + geom_point()
Pi1_Pi4 <- ggplot(dat, aes(pull(dat, 9), pull(dat, 12))) + geom_point()
Pi2_Pi3 <- ggplot(dat, aes(pull(dat, 10), pull(dat, 11))) + geom_point()
Pi2_Pi4 <- ggplot(dat, aes(pull(dat, 10), pull(dat, 12))) + geom_point()
Pi3_Pi4 <- ggplot(dat, aes(pull(dat, 11), pull(dat, 12))) + geom_point()
plot.new()
plot_grid(
  P1_P2, P1_P3, P1_P4, P2_P3, P2_P4, P3_P4,
  labels = c("Phi1 vs Phi2", "Phi1 vs Phi3", "Phi1 vs Phi4",
             "Phi2 vs Phi3", "Phi2 vs Phi4", "Phi3 vs Phi4"),
  align = "hv"
)


# limma package link: http://bioconductor.org/packages/release/bioc/html/limma.html
# Before limma is called, intensity data are transformed using log2. To change this to log10, replace with
# res <- limmaDE(prodat.med, transform.fun=log10)
# Perform differential expression on the normalized protein data
# This function can only be used on 2 conditions at a time. 
results_Phos_BH <- limmaDE_adjust(prot.MQ, conditions = c("NO_Phos", "Phos"), limma_adjust = "BH")
results_Phi_BH <- limmaDE(prot.MQ, conditions = c("NO_Phos", "Phi"), limma_adjust = "BH")

# Changing the limma_adjust to none seems to have little to no effect on the result.
results_Phos_None <- limmaDE_adjust(prot.MQ, conditions = c("NO_Phos", "Phos"), limma_adjust = "none")
results_Phi_None <- limmaDE_adjust(prot.MQ, conditions = c("NO_Phos", "Phi"), limma_adjust = "none")

# plot the results using a live, alterable Volcano Plot:
# We strongly recommend to build protein annotations before running live functions.
plotVolcano_live(prot.MQ, results_Phos_BH)
plotVolcano_live(prot.MQ, results_Phi_BH)

plotVolcano_live(prot.MQ, results_Phos_None)
plotVolcano_live(prot.MQ, results_Phi_None)
#Plot a line with adjusted p-value threshold of 0.05 

#Add a column with regular p-value as well (need to alter the limmaDE function from Proteus)
plotPdist(results_Phi)
plotPdist(results_Phos)
