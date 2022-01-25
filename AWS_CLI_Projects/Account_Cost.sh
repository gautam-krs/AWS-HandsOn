#!/bin/bash

Acct_Name=$(aws organizations list-accounts --query Accounts[*].Id --output text)
array=$Acct_Name
for i in ${array[@]}
do
	echo "Account Name: "$i
    aws ce get-cost-and-usage --profile $i \
    --time-period Start=2022-01-01,End=2022-02-01 \
    --granularity MONTHLY \
    --metrics "BlendedCost" 
done 
