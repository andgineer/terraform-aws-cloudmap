# strange extension because of bug https://github.com/VladRassokhin/intellij-hcl/issues/201
region           = "eu-west-2"
# To find your VPC ID, run: aws ec2 describe-vpcs --region eu-west-2 --query 'Vpcs[*].[VpcId,IsDefault,CidrBlock]' --output table
vpc_id           = "vpc-0fdedac91e1f252a1"

ecs_ec2_image = "hello-world"
ecs_fargate_image= "hello-world"

cloudmap_namespace = "my-namespace"
