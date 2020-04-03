import string, re

def center_peptides(file_name):
    cutoff = input("Please enter the cutoff percentage for peptide probability: ")
    while not re.match("^[0-9]*$", cutoff):
        if cutoff == 'q':
            exit()
        print("The percentage must be an integer. Do not include a '%' symbol.")
        cutoff = input("Please enter the cutoff percentage for peptide probability: ")
    cutoff = float(cutoff)
    altered_file = open("outputs/peptides_centered.txt", "w")
    with open(file_name) as file_obj:
        i=0
        pep_index = None
        prot_index = None
        sequence_index = None
        for line in file_obj:
            cols = line.split("\t")
            if i==0:
                for j in range(0, len(cols)):
                    if cols[j] == "Phospho (STY) Probabilities":
                        pep_index = j
                    if cols[j] == "Protein":
                        prot_index = j
                    if cols[j] == "Sequence window":
                        sequence_index = j
                i = i + 1
                altered_file.write(line)
                continue
            
            line_to_write = cols[prot_index] + "\t" + cols[pep_index] + "\t" + cols[sequence_index]
            pass_cutoff= False
            phos_indices = []
            pep_seq = cols[pep_index]
            for j in range(0, len(pep_seq)):
                if pep_seq[j] == "(":
                    phos_indices.append(j-1)
                #ensure the peptide has a valid % number
                percentage = percentages[j].split(")") #remove closing bracket
                if len(percentage) >= 2:
                    percentage = percentage[0] # now the first index has the number itself, eg. ["0.95", "..."]
                    percentage = float(percentage) # turn the string into a number. eg. "0.95" becomes 0.95
                    if (percentage*100) >= cutoff:
                        pass_cutoff = True
                        peptide_percentage_indices.append(j)

            if not pass_cutoff:
                line_to_write = None

            while re.match("^[\s]*$", line_to_write[-1]):
                line_to_write = line_to_write[:-1]
            line_to_write = line_to_write + "\n"
            altered_file.write(line_to_write)
            i = i + 1
    altered_file.close()

center_peptides("proteus_data/practice_data_files/TP_XYZ/txt/Phospho (STY)Sites.txt")