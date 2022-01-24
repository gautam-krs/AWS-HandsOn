#Set an IAM password policy
aws iam  update-account-password-policy \
--minimum-password-length 10 \
--require-symbols \
--require-numbers \
--require-uppercase-characters \
--require-lowercase-characters \
--allow-users-to-change-password \
--max-password-age 90 \
--password-reuse-prevention 5

#Create an IAM Group for ReadOnly Billing Access
aws iam create-group --group-name AWSBilling

#Attach the AWSReadOnlyAccess policy to this group.
aws iam attach-group-policy --group-name AWSBilling \
--policy-arn arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess 

#Attach the AWSReadOnlyAccess policy to this group.
aws iam create-user --user-name BillingUser

#Use Secrets manager to generate a password that conforms to your password policy.
Create an IAM user named BillingUser
Password=$(aws secretsmanager get-random-password \
--password-length 10 --require-each-included-type \
--output text \
--query RandomPassword)

#Create a login profile for the user that specifies a password.
aws iam create-login-profile --user-name BillingUser --password $Password

#Add the user to the group you created for read only billing address.
aws iam add-user-to-group --group-name AWSBilling --user-name BillingUser

#Verify the password policy set by you is now active
aws iam get-account-password-policy

#Create a new user and try to associate a password that violates the above policy
aws iam create-user --user-name BillingUser1

Password=$(aws secretsmanager get-random-password \
--password-length 8 --require-each-included-type \
--output text \
--query RandomPassword)

aws iam create-login-profile --user-name BillingUser1 --password $Password