#!/bin/bash

#This script extract stackset name from the stack

#List all the stcks from an account
stack_name=$(aws cloudformation list-stacks --profile 928844814809 --query StackSummaries[*].StackName --output text)
for word in $stack_name;
do echo ${word:0:-37}|cut -c 10-;
done

