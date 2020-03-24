import string

def alter_useful_peptide_names(file_name):
    altered_file = open("peptides_altered.txt", "w")
    with open(file_name) as file_obj:
        i=0
        pep_index = None
        prot_index = None
        for line in file_obj:
            cols = line.split("\t")
            if i==0:
                for j in range(0, len(cols)):
                    if cols[j] == "peptide***":
                        pep_index = j
                    if cols[j] == "protein***":
                        prot_index = j
                continue
            
            peptide_percentage = cols[pep_index].split("(")

            #ensure the peptide has a valid % number
            if len(peptide_percentage < 2):
                continue

            # the last index has the number itself, along with a closing bracket, eg. ["peptidename", "0.95)..."]
            peptide_percentage = peptide_percentage[-1] 
            peptide_percentage = peptide_percentage.split(")") #remove closing bracket
            peptide_percentage = peptide_percentage[0] # now the first index has the number itself, eg. ["0.95", "..."]
            peptide_percentage = float(peptide_percentage) # turn the string into a number. eg. "0.95" becomes 0.95

            line_to_write = ""
            if peptide_percentage >= 0.75:
                for j in range(0, len(cols)):
                    if (j == pep_index):
                        line_to_write = line_to_write + line[prot_index] + "_" + line[pep_index] + "\t"
                    else:
                        line_to_write = line_to_write + line[j] + "\t"
            else:
                line_to_write = line
            
            altered_file.write(line_to_write)

