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
library(dplyr)
library(pheatmap)
#import the modified functions needed for this script
source("functions.R")

args <- commandArgs()
#exclude the entries not pertaining to input values
conditions <- args[-(1:8)]
control_condition <- args[8]
num_samples <- 4


#SECTION: Read input data
# read the metadata file
meta <- read.delim("/Users/cameronridderikhoff/Documents/CMPUT399/BioInformatics_Protiens_Peptides/proteus_data/practice_data_files/TP_XYZ/txt/meta.txt", header = TRUE, sep = "\t", dec = ".")

# (Section 5.5 Reading MaxQuant’s protein groups file)
# Read the proteinGroups file from MaxQuant directly, and immediately turn it into something useful for Proteus
prot.filename <- "/Users/cameronridderikhoff/Documents/CMPUT399/BioInformatics_Protiens_Peptides/proteus_data/practice_data_files/TP_XYZ/txt/proteinGroups.txt"
prot.PG <- readProteinGroups(prot.filename, meta)


#SECTION: Plot graphs of data

# Plot histogram and boxplot of log2 transformed data 
plot <- plotSampleDistributions(prot.PG, method = "dist", log.base = 2) #plots histogram plots of the intensities/ratios of each sample
ggsave(plot, file=paste('/Users/cameronridderikhoff/Documents/CMPUT399/BioInformatics_Protiens_Peptides/outputs/',
                        "log2histogram", ".png", sep=''), scale=2)

plot <- plotSampleDistributions(prot.PG, log.base = 2) #plots box plots of the intensities/ratios of each sample
ggsave(plot, file=paste('/Users/cameronridderikhoff/Documents/CMPUT399/BioInformatics_Protiens_Peptides/outputs/',
                        "log2boxplot", ".png", sep=''), scale=2)

#perform log2 transformation on the data so we acn do scatterplots
prot.dat <- data.frame(log2(prot.PG$tab))
i <- 0
for (condition in conditions) {
  for (sample in 1:num_samples) {
    for (sample_against in sample:num_samples) {
      if (sample_against != sample) {
        plot <- ggplot(prot.dat, aes(pull(prot.dat, sample), pull(prot.dat, sample_against))) + geom_point()
        #print(plot)
        # save plots as .pdf
        ggsave(plot, file=paste('/Users/cameronridderikhoff/Documents/CMPUT399/BioInformatics_Protiens_Peptides/outputs/',
                              condition, "_", "sample", sample, "_vs_", sample_against, ".png", sep=''), scale=2)
      }
    }
  }
  i <- i + length(num_samples)
}

# limma package link: http://bioconductor.org/packages/release/bioc/html/limma.html
# Before limma is called, intensity data are transformed using log2. To change this to log10, replace with
# res <- limmaDE(prodat.med, transform.fun=log10)
# Perform differential expression on the normalized protein data
# This function can only be used on 2 conditions at a time. 

for (i in 1:length(conditions)) {
  if (conditions[i] != control_condition) {
    
    results_BH <- limmaDE_adjust(prot.PG, conditions = c(control_condition, conditions[i]), limma_adjust = "BH")
    write.csv(results_BH, file = paste('/Users/cameronridderikhoff/Documents/CMPUT399/BioInformatics_Protiens_Peptides/outputs/',
                                       "results", control_condition, "_vs_", conditions[i], ".csv"))
    # plot the results using a Volcano Plot and save to a png:
    plot <- plotVolcano_pvalue(results_BH, pval = 0.05, pval_type = "unadjusted")
    ggsave(plot, file=paste('/Users/cameronridderikhoff/Documents/CMPUT399/BioInformatics_Protiens_Peptides/outputs/',
                      conditions[i], "_", "Results_BH", "_unadjusted_pvalue", "_VolcanoPlot.png", sep=''), scale=2)

    plot <- plotVolcano_pvalue(results_BH, pval = 0.05, pval_type = "adjusted")
    ggsave(plot, file=paste('/Users/cameronridderikhoff/Documents/CMPUT399/BioInformatics_Protiens_Peptides/outputs/',
                            conditions[i], "_", "Results_BH", "_adjusted_pvalue", "_VolcanoPlot.png", sep=''), scale=2)
    
    pheatmap(results_BH, filename = paste('/Users/cameronridderikhoff/Documents/CMPUT399/BioInformatics_Protiens_Peptides/outputs/',
                                                      conditions[i], "_", "Results_BH", "_Pheatmap.png", sep=''))
    
    # Changing the limma_adjust to none seems to have little to no effect on the result.
    #results_None <- limmaDE_adjust(prot.PG, conditions = c(control_condition, conditions[i]), limma_adjust = "none")
    #plot <- plotVolcano_pvalue(results_None, pval = 0.05)
    #ggsave(plot, file=paste('/Users/cameronridderikhoff/Documents/CMPUT399/BioInformatics_Protiens_Peptides/outputs/',
    #                        conditions[i], "_", "Results_None","_VolcanoPlot.png", sep=''), scale=2)
  }
}

#Add a column with regular p-value as well (need to alter the limmaDE function from Proteus)
#Might be called "p-value" for uncorrected and q-value for corrected
#Volcano plot function only plots P-value, so we need to check the data frame

#Make a spreadsheet of limma_adjusted data (CSV) - do just one before trying to merge, may want to merge the two together 
#we want: NO_Phos median, Phos average, Phi average, AGI, Description
#use this data to perform PHEATMAP, KEGG, and SetRank


#finish comments of both R files and Python files, and clean up
