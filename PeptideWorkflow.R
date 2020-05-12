# Cameron Ridderikhoff, University of Alberta, 2020

# To see some information pertaining to the following code,
# Run the command:
# >vignette("proteus", package="proteus")


#SECTION: Imports
# libary(x) tells R what library, or set of functions, it needs to use.

library(proteus) # For proteus functions like: readProteinGroups, limmaDE, and more.
library(ggplot2) # For scatter, box, and Volcano plots, and saving of the plots.
library(dplyr) # dplyr contains many helper functions required for this code.
library(tidyr) # Contains more helper functions
library(pheatmap) # For the creation of a pheatmap.
library(stringr)

# Import the modified functions created for this script
source("functions.R")


#SECTION: Read input data and remove useless peptides

# Import the conditions and number of samples from the Python script that runs this workflow "run_proteus_workflow.py"
args <- commandArgs()
conditions <- args[-(1:9)] # Exclude the entries not pertaining to input values
control_condition <- args[9] # The control condition is located at index 9
num_samples <- strtoi(args[8]) # The number of samples is located at index 8, turn it from a string to an integer

# Read the metadata file
meta <- read.delim("data/meta.txt", header = TRUE, sep = "\t", dec = ".")

# (Section 2.2 Reading evidence file)
# Read the evidence file from MaxQuant directly, and immediately turn it into something useful for Proteus
evi.filename <- "data/evidence.txt"
evi <- readEvidenceFile(evi.filename)

# Open peptides_altered.txt
pepToKeep <- read.delim("outputs/peptides_altered.txt")
# Extract the peptide sequences
pepToKeep.names <- data.frame(x = pepToKeep$Phospho..STY..Probabilities)
pepNames <- pepToKeep.names %>% separate(x, c(NA, "Peptide"), "_")
pepNames <- as.vector(pepNames[,])

# Make a peptide table with the evidence file and the metadata file
pepdat <- makePeptideTable(evi, meta)
peptab <- pepdat$tab

# Remove the rows that are in the evidence file, but not in the Phospho STY "to keep" peptide list.
peptab = peptab[row.names(peptab) %in% pepNames, ]
pepdat$tab <- peptab


#SECTION: Plots

# Plot histogram, dendrogram and boxplot of log2 transformed data 
plot <- plotSampleDistributions(pepdat, method = "dist", log.base = 2) #plots histogram plots of the intensities/ratios of each sample
ggsave(plot, file="outputs/peptide_log2_histogram.png", scale=2)

plot <- plotSampleDistributions(pepdat, log.base = 2) #plots box plots of the intensities/ratios of each sample
ggsave(plot, file="outputs/peptide_log2_boxplot.png", scale=2)
# Plot a dendrogram of the peptide data set
plot <- plotClustering(pepdat) 
ggsave(plot, file="outputs/peptide_dendrogram.png", scale=2)

# Plot Jaccard Similarity of data
plot <- plotDetectionSimilarity(pepdat, bin.size=0.02)
ggsave(plot, file="outputs/peptide_jaccard_similarity.png", scale=2)

# Plot the Pearson’s correlation coefficient in a Distance matrix
plot <- plotDistanceMatrix(pepdat)
ggsave(plot, file="outputs/peptide_distance_matrix.png", scale=2)

# Perform log2 transformation on the data so we can do scatterplots
peptab <- data.frame(peptab)
for (condition in conditions) { # For every condition that we have:
  for (sample in 1:num_samples) { # For every sample in each condition:
    # This part is a bit complicated. In order to not have multiple copies of the same graph, ie 2vs3 and 3vs2, 
    # we start from the sample number we are at, and reiterate over the rest of the samples
    for (sample_against in sample:num_samples) { 
      if (sample_against != sample) { # Make sure we are not graphing a sample against itself
        # Create the scatterplot of the log2 transformed data
        plot <- ggplot(peptab, aes(pull(peptab, sample), pull(peptab, sample_against))) + geom_point()
        # Save plots as .png
        ggsave(plot, file=paste("outputs/peptide_", condition, "_sample", sample, 
                                "_vs_", sample_against, "_scatter.png", sep=''), scale=2)
      }
    }
  }
}

# Save the pheatmap to a .png
peptab[is.na(peptab)] <- 0 # n/a's, must be 0's for pheatmap to work
pheatmap(peptab, show_rownames = FALSE, filename = "outputs/peptide_pheatmap.png")

# limma package link: http://bioconductor.org/packages/release/bioc/html/limma.html
# Before limma is called, intensity data are transformed using log2. To change this to log10, replace with
# results_BH <- limmaDE_adjust(prot.PG, transform.fun=log10, conditions = c(control_condition, conditions[i]), limma_adjust = "BH")
# Perform differential expression on the normalized protein data
# This function can only be used on 2 conditions at a time. 

for (i in 1:length(conditions)) { # For each condition:
  if (conditions[i] != control_condition) { # Exclude the control condition
    
    # Call limmaDE_adjust to get p-values for the differential expression altered data
    results_BH <- limmaDE_adjust(pepdat, conditions = c(control_condition, conditions[i]), limma_adjust = "BH")
    # Save the results in a csv file.
    write.csv(results_BH, file = paste("outputs/peptide_results", 
                                       control_condition, "_vs_", conditions[i], ".csv"))
    
    # Plot the unadjusted p values using a Volcano Plot and save to a png and a pdf:
    plot <-  plotVolcano_pvalue(results_BH, pval = 0.05, pval_type = "unadjusted")
    ggsave(plot, file=paste("outputs/peptide_", conditions[i], 
                            "_BH_unadjusted_p_volcano.png", sep=''), scale=2)
    ggsave(plot, file=paste("outputs/peptide_", conditions[i],
                            "_BH_unadjusted_p_volcano.pdf", sep=''), scale=2)
    
    # Plot the adjusted p values using a Volcano Plot and save to a png and a pdf:
    plot <- plotVolcano_pvalue(results_BH, pval = 0.05, pval_type = "adjusted")
    ggsave(plot, file=paste("outputs/peptide_", conditions[i], 
                            "_BH_adjusted_p_volcano.png", sep=''), scale=2)
    ggsave(plot, file=paste("outputs/peptide_", conditions[i],
                            "_BH_adjusted_p_volcano.pdf", sep=''), scale=2)
    }
}