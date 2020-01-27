import string

meta = open("proteus_data/practice_data_files/TP_XYZ/txt/meta.txt", 'w')
meta.write("experiment\tmeasure\tsample\tcondition\n")

num_samples = input("Please enter the number of samples: ")

conditions = []
while "e" not in conditions:
    conditions.append(input("Please enter the name of one of the conditions, or press 'e' to exit: "))

conditions.pop() #remove the "e" from conditions, so as to avoid adding it to the metadata file

measure = "Intensity"
for condition in conditions:
    for i in range(1, int(num_samples) + 1):
        experiment = condition + "_" + str(i)
        sample = experiment
        meta.write(experiment + "\t" + measure + "\t" + sample + "\t" + condition + "\n")

meta.close()
print("Metadata file successfully generated.")