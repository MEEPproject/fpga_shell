PRIVATE_TOKEN=$1
NEW_VALUE=$2

GITLAB_URL="https://gitlab.bsc.es/"
project="FPGA_implementations%2FAlveoU280%2Ftest_cicd"
group="meep"


response=$(curl --request POST "$GITLAB_URL/api/v4/projects/${group}%2F${project}/variables" \
 --form "key=LAST_SUCCESS" \
 --form "value=$NEW_VALUE" \
 --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" )
 
 echo "$response"
	 

#Update	 
# curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>" \
     # "https://gitlab.example.com/api/v4/groups/1/variables/NEW_VARIABLE" --form "value=updated value"	 

# #Remove	 
# curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
     # "https://gitlab.example.com/api/v4/groups/1/variables/VARIABLE_1"