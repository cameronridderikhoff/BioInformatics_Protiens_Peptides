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
library(rlist)
library(dplyr)

samples <- list(first = "NO_Phos", second = "Phos", third = "Phi")
control_sample <- "NO_Phos"
num_trials <- 4

#SECTION: Read input data
# read the metadata file
meta <- read.delim("/Users/cameronridderikhoff/Documents/CMPUT399/BioInformatics_Protiens_Peptides/proteus_data/practice_data_files/TP_XYZ/txt/meta.txt", header = TRUE, sep = "\t", dec = ".")

# (Section 5.5 Reading MaxQuant’s protein groups file)
# Read the proteinGroups file from MaxQuant directly, and immediately turn it into something useful for Proteus
prot.filename <- "/Users/cameronridderikhoff/Documents/CMPUT399/BioInformatics_Protiens_Peptides/proteus_data/practice_data_files/TP_XYZ/txt/proteinGroups.txt"
prot.PG <- readProteinGroups(prot.filename, meta)


#SECTION: Plot graphs of data

# Plot histogram and boxplot of log2 transformed data 
plotSampleDistributions(prot.PG, method = "dist", log.base = 2) #plots histogram plots of the intensities/ratios of each sample
plotSampleDistributions(prot.PG, log.base = 2) #plots box plots of the intensities/ratios of each sample

#perform log2 transformation on the data so we acn do scatterplots
prot.dat <- data.frame(log2(prot.PG$tab))
i <- 0
for (sample in samples) {
  for (trial in 1:num_trials) {
    for (trial_against in trial:num_trials) {
      if (trial_against != trial) {
        plot <- ggplot(prot.dat, aes(pull(prot.dat, trial), pull(prot.dat, trial_against))) + geom_point()
        #print(plot)
        # save plots as .pdf
        ggsave(plot, file=paste('/Users/cameronridderikhoff/Documents/CMPUT399/BioInformatics_Protiens_Peptides/outputs/',
                              sample, "_", "Trial", trial, "_vs_", trial_against, ".pdf", sep=''), scale=2)
      }
    }
  }
  i <- i + length(num_trials)
}

# limma package link: http://bioconductor.org/packages/release/bioc/html/limma.html
# Before limma is called, intensity data are transformed using log2. To change this to log10, replace with
# res <- limmaDE(prodat.med, transform.fun=log10)
# Perform differential expression on the normalized protein data
# This function can only be used on 2 conditions at a time. 
results_BH <- array(dim = length(samples))
results_None <- array(dim = length(samples))
for (i in 1:length(samples)) {
  if (samples[i] != control_sample) {
    
    results_BH[i] <- limmaDE_adjust(prot.MQ, conditions = c(control_sample, samples[i]), limma_adjust = "BH")
    # plot the results using a live, alterable Volcano Plot:
    # "We strongly recommend to build protein annotations before running live functions."
    plotVolcano_live(prot.MQ, results_BH[i])
    plotPdist(results_BH[i])
    # Changing the limma_adjust to none seems to have little to no effect on the result.
    results_None[i] <- limmaDE_adjust(prot.MQ, conditions = c(control_sample, samples[i]), limma_adjust = "none")
    plotVolcano_live(prot.MQ, results_None[i])
  }
}

#Plot a line with adjusted p-value threshold of 0.05 

#Add a column with regular p-value as well (need to alter the limmaDE function from Proteus)
