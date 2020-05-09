import re, string

def remove_useless_peptides(file_name):
    # Get the user to enter the cutoff for the peptides that will be removed
    cutoff = input("Please enter the cutoff percentage for useful peptide probability: ")
    while not re.match("^[0-9]*$", cutoff):
        if cutoff == 'q':
            exit()
        print("The percentage must be an integer. Do not include a '%' symbol.")
        cutoff = input("Please enter the cutoff percentage for useful peptide probability: ")
    cutoff = float(cutoff)

    # We save the saved peptides in a new file called "peptides_altered.txt" in the "outputs" folder 
    altered_file = open("outputs/peptides_altered.txt", "w")
    with open(file_name) as file_obj:
        i=0
        # This number is the index of the "Phospho STY Probablities", to get the sequence of the peptide
        pep_index = None
        # This number is the index of the "Protein" column, to get the name of the protein
        prot_index = None
        # Go through every line in the file
        for line in file_obj:
            cols = line.split("\t")
            # The first line in the file contains the column names, so we extract the above indices
            if i==0:
                for j in range(0, len(cols)):
                    if cols[j] == "Phospho (STY) Probabilities":
                        pep_index = j
                    if cols[j] == "Protein":
                        prot_index = j
                i = i + 1
                altered_file.write(line)
                continue
            
            # This holds the percentages that exist in the peptide sequences
            percentages = cols[pep_index].split("(")
            if len(percentages) < 2: #if there is no phosphorylation site in this peptide, ignore it
                continue
            # We assume the line does not pass the cutoff until we find a percentage that does pass
            pass_cutoff = False
            for percentage in percentages:
                #ensure the peptide has a valid % number
                percentage = percentage.split(")") #remove closing bracket
                if len(percentage) >= 2:
                    percentage = percentage[0] # now the first index has the number itself, eg. ["0.95", "..."]
                    percentage = float(percentage) # turn the string into a number. eg. "0.95" becomes 0.95
                    if (percentage*100) >= cutoff:
                        pass_cutoff = True

            # Extra the sequence of the peptide in "pep_name"
            pep_name = ""
            for char in cols[pep_index]:
                #get the name of the peptide and add it to pep_name
                if re.match("^[A-Z]*$", char):
                    pep_name = pep_name + char
            
            # If the line passes the cutoff
            line_to_write = ""
            if pass_cutoff:
                for j in range(0, len(cols)):
                    if (j == pep_index):
                        # Add the protein name to the peptide sequence and save it
                        line_to_write = line_to_write + cols[prot_index] + "_" + pep_name + "\t"
                    else:
                        # Save the rest of the line
                        line_to_write = line_to_write + cols[j] + "\t"

                # This loop removes any spare whitespace on the end of the line. This is done to avoid errors.
                while re.match("^[\s]*$", line_to_write[-1]):
                    line_to_write = line_to_write[:-1]
                # Add a newline character to the end of the line
                line_to_write = line_to_write + "\n"
                # Write the line to the file
                altered_file.write(line_to_write)
            else:
                line_to_write = line
            # This "i" is only really useful for the first line, it could just as easily be a boolean,
            # but it doesn't take much computing power to increment a single variable, and this is easy.
            i = i + 1
    # Close the file to save it for later use.
    altered_file.close()
