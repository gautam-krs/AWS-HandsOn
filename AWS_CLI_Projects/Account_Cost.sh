#!/bin/bash

#List All the Accouns within the organization
Acct_Name=$(aws organizations list-accounts --query Accounts[*].Id --output text)
array=$Acct_Name
for i in ${array[@]}
do
    #Generates the blended cost for all the accounts in loop
    echo "Cost for Account : " $i
	aws ce get-cost-and-usage --profile $i \
    --time-period Start=2022-01-01,End=2022-02-01 \
    --granularity MONTHLY \
    --metrics "BlendedCost" \
    --query ResultsByTime[*].Total.BlendedCost


done 
