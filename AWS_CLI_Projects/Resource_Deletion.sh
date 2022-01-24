#!/bin/bash

#Pass Account Name and Number as Parameter
AccountNameParam=$1
AccountNumberParam=$2

#Verify the Account Name and Nubmer passed in the param matches with Account where AWS CLI is running
Acct_Number=$(aws sts get-caller-identity --query Account --output text)
Acct_Name=$(aws organizations describe-account --account-id $Acct_Number --query Account.Name --output text)
echo "Account Name : "$Acct_Name 
echo "Account Number : "$Acct_Number

#Check whether they are not equal
if [[ $AccountNameParam != $Acct_Name || $AccountNumberParam != $Acct_Number ]] ;
then
    echo "Account details passed in param doesn't matches with AWS CLI Account";
    exit 1;
else 
    echo "Proceeding with Account Deletion"
fi

#List S3 Bucket for the Account
echo "Listing S3 BUCKETS for Account : " $1 $2
aws s3api list-buckets --query Buckets[].Name

s3_buckets=$(aws s3api list-buckets --query Buckets[].Name --output text)
# Check if you want to delete the resource
echo "Do you want to Delete S3 buckets? Please enter yes or no"
read n
yes=$(echo $n | tr -s '[:upper:]' '[:lower:]')
if [[  "$n" = "yes"  ]] ;
then
array=$s3_buckets
for i in ${array[@]}
do
	echo "Deleteting S3 bucket: "$i
    #Removes all the files from the bucket
    #aws s3 rm s3://$i --recursive --dryrun
    #aws s3 rb s3://$i --force
done 
else
    echo "Exitting the delete mode"
    exit 
fi

##Ec2 Instances deletion

echo "Listing EC2 Resources for Account : " $1 $2
aws ec2 describe-instances --query Reservations[].Instances[].InstanceId
ec2_instance=$(aws ec2 describe-instances --query Reservations[].Instances[].InstanceId --output text)

# Check if you want to delete the resource
echo "Do you want to terminate EC2 instances? Please enter yes or no"
read n
yes=$(echo $n | tr -s '[:upper:]' '[:lower:]')
if [[  "$n" = "yes"  ]] ;
then
array=$ec2_instance
for i in ${array[@]}
do
	echo "Terminating EC2 Instance : "$i
    aws ec2 terminate-instances --instance-ids $i
    echo $i "is terminated"
done 
else
    echo "Exitting the delete mode"
    exit 
fi

#Lambda Functions

echo "Listing Lambda Function for Account : " $1 $2
aws lambda list-functions --query Functions[].FunctionName
lambda_function=$(aws lambda list-functions --query Functions[].FunctionName --output text)

# Check if you want to delete the resource
echo "Do you want to delete Lambda Functions? Please enter yes or no"
read n
yes=$(echo $n | tr -s '[:upper:]' '[:lower:]')
if [[  "$n" = "yes"  ]] ;
then
array=$lambda_function
for i in ${array[@]}
do
	echo "Deleting Lambda Function : "$i
    aws lambda delete-function --function-name $i
    echo $i "is deleted"
done 
else
    echo "Exitting the delete mode"
    exit 
fi

###########Stacks Deletion###############################
echo "Listing Stacks for Account : " $1 $2
aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE
stacks=$( aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE --query StackSummaries[].StackName --output text)
# Check if you want to delete the resource
echo "Do you want to delete the Stacks? Please enter yes or no"
read n
yes=$(echo $n | tr -s '[:upper:]' '[:lower:]')
if [[  "$n" = "yes"  ]] ;
then
array=$stacks
for i in ${array[@]}
do
	echo "Deleting Stack : "$i
    aws cloudformation delete-stack --stack-name $i
    echo $i "is deleted"
done 
else
    echo "Exitting the delete mode"
    exit 
fi


###########Cloudwatch LogGroup Deletion###############################
echo "Listing Cloudwatch LogGroup for Account : " $1 $2
aws logs describe-log-groups --query logGroups[].logGroupName
log_groups=$(aws logs describe-log-groups --query logGroups[].logGroupName --output text)
# Check if you want to delete the resource
echo "Do you want to delete the Cloudwatch Log Groups? Please enter yes or no"
read n
yes=$(echo $n | tr -s '[:upper:]' '[:lower:]')
if [[  "$n" = "yes"  ]] ;
then
array=$log_groups
for i in ${array[@]}
do
	echo "Deleting log group : "$i
    aws logs delete-log-group --log-group-name $i
    echo $i "is deleted"
done 
else
    echo "Exitting the delete mode"
    exit 
fi
exit  