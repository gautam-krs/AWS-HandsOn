#!/bin/bash
#set the default resion
export AWS_REGION=us-east-1

#Create a VPC with CIDR 10.10.0.0/16
VPC_ID=$(aws ec2 create-vpc --cidr-block 10.10.0.0/16 \
--tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=My-Test-VPC}]' \
--query Vpc.VpcId --output text )

#Verify that VPC is created as expected
aws ec2 describe-vpcs --vpc-ids $VPC_ID

#Create two subnets, one in each AZ
SUBNET_ID_1=$(aws ec2 create-subnet --vpc-id $VPC_ID \
    --cidr-block 10.10.0.0/24 --availability-zone ${AWS_REGION}a \
    --tag-specifications \
    'ResourceType=subnet,Tags=[{Key=Name,Value=test-subnet-a}]' \
    --output text --query Subnet.SubnetId)

SUBNET_ID_2=$(aws ec2 create-subnet --vpc-id $VPC_ID \
    --cidr-block 10.10.1.0/24 --availability-zone ${AWS_REGION}b \
    --tag-specifications \
    'ResourceType=subnet,Tags=[{Key=Name,Value=test-subnet-b}]' \
    --output text --query Subnet.SubnetId)

#Create a route table
ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID \
    --tag-specifications \
    'ResourceType=route-table,Tags=[{Key=Name,Value=TestRoutetable}]' \
    --output text --query RouteTable.RouteTableId)

#Associate Route tables with the subnet
aws ec2 associate-route-table \
    --route-table-id $ROUTE_TABLE_ID --subnet-id $SUBNET_ID_1

aws ec2 associate-route-table \
    --route-table-id $ROUTE_TABLE_ID --subnet-id $SUBNET_ID_2

#Verify the configuration of the subnets to check they are in same vpc and two AZs
aws ec2 describe-subnets --subnet-ids $SUBNET_ID_1
aws ec2 describe-subnets --subnet-ids $SUBNET_ID_2

#Validate that the route table you created is associated with the two subnets:
aws ec2 describe-route-tables --route-table-ids $ROUTE_TABLE_ID

######Cleanup#########

#Delete your subnets:
aws ec2 delete-subnet --subnet-id $SUBNET_ID_1
aws ec2 delete-subnet --subnet-id $SUBNET_ID_2

#Delete your route table:
aws ec2 delete-route-table --route-table-id $ROUTE_TABLE_ID

#Delete your VPC:
aws ec2 delete-vpc --vpc-id $VPC_ID

#Unset your manually created environment variables"
unset VPC_ID
unset ROUTE_TABLE_ID
unset SUBNET_ID_1
unset SUBNET_ID_2