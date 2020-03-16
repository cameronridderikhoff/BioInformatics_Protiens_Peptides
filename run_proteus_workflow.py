import string
import subprocess
import re
import create_metadata_file
import remove_insignificant_proteins

R_args = create_metadata_file()

remove_insignificant_proteins()

return_code = subprocess.call("Rscript --vanilla -e 'source(\"ProteusWorkflow.R\")'" + R_args, shell=True)
if return_code != 0:
    print("Script failed with code: " + str(return_code))
else:
    print("Script passed with code: " + str(return_code))
