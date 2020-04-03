import string, re

def alter_useful_peptide_names(file_name):
    cutoff = input("Please enter the cutoff percentage for useful peptide probability: ")
    while not re.match("^[0-9]*$", cutoff):
        if cutoff == 'q':
            exit()
        print("The percentage must be an integer. Do not include a '%' symbol.")
        cutoff = input("Please enter the cutoff percentage for useful peptide probability: ")
    cutoff = float(cutoff)
    altered_file = open("outputs/peptides_altered.txt", "w")
    with open(file_name) as file_obj:
        i=0
        pep_index = None
        prot_index = None
        for line in file_obj:
            cols = line.split("\t")
            if i==0:
                for j in range(0, len(cols)):
                    if cols[j] == "Phospho (STY) Probabilities":
                        pep_index = j
                    if cols[j] == "Protein":
                        prot_index = j
                i = i + 1
                altered_file.write(line)
                continue
            
            percentages = cols[pep_index].split("(")
            if len(percentages) < 2: #if there is no phosphorylation site in this 
                continue
            pass_cutoff= False
            for percentage in percentages:
                #ensure the peptide has a valid % number
                percentage = percentage.split(")") #remove closing bracket
                if len(percentage) >= 2:
                    percentage = percentage[0] # now the first index has the number itself, eg. ["0.95", "..."]
                    percentage = float(percentage) # turn the string into a number. eg. "0.95" becomes 0.95
                    if (percentage*100) >= cutoff:
                        pass_cutoff = True

            line_to_write = ""
            if pass_cutoff:
                for j in range(0, len(cols)):
                    if (j == pep_index):
                        line_to_write = line_to_write + cols[prot_index] + "_" + cols[pep_index] + "\t"
                    else:
                        line_to_write = line_to_write + cols[j] + "\t"
            else:
                line_to_write = line

            while re.match("^[\s]*$", line_to_write[-1]):
                line_to_write = line_to_write[:-1]
            line_to_write = line_to_write + "\n"
            altered_file.write(line_to_write)
            i = i + 1
    altered_file.close()

alter_useful_peptide_names("proteus_data/practice_data_files/TP_XYZ/txt/Phospho (STY)Sites.txt")