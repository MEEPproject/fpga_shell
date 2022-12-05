#!\bin\bash

# This converts the date (from epoc) to hexadecimal value
printf '%x\r\n' $(date +%s)
# This extracts the short SHA
git rev-parse --short HEAD


# Convert to decimal the stored hexadecimal 
printf '%d\n' `echo $output`
# ... so it can be read by date
date --date @${output}
