# Let's play with Spring Boot and AWS Fargate

![High Level Overview](drawio/overview.png)

Target Architecture:
- Load balancer: Application Load Balancer (with TLS-termination)
- Web application: containerized Java (Spring Boot-) application running as a AWS Fargate service
- Database: Amazon RDS for MySQL instance

## Network Security

![Security Groups](drawio/securitygroups.png)
 
Requirements:
- End user web browsers can only communicate with the load balancer (HTTPS, port 443)
- Only the load balancer can communicate with the web application (HTTP, port 8080)
- Only the web application can communicate with the database (MySQL, port 3306)

Properly configured VPC Security Groups meet these requirements.

CloudFormation yaml template (some details omitted):

    ...
    Resources:
        LoadBalancerSG:
            Type: AWS::EC2::SecurityGroup
            Properties: 
            GroupDescription: HTTPS
            SecurityGroupIngress: 
                -  IpProtocol: "tcp"
                   FromPort: 443
                   ToPort: 443
                   CidrIp: "0.0.0.0/0"
                   VpcId: !Ref VPC

        ApplicationSG:
            Type: AWS::EC2::SecurityGroup
            Properties: 
            GroupDescription: HTTP 8080
            SecurityGroupIngress: 
                -  IpProtocol: "tcp"
                   FromPort: 8080
                   ToPort: 8080
                   SourceSecurityGroupId: !GetAtt LoadBalancerSG.GroupId
            VpcId: !Ref VPC

        DatabaseSG:
            Type: AWS::EC2::SecurityGroup
            Properties: 
            GroupDescription: MySQL
            SecurityGroupIngress: 
                -  IpProtocol: "tcp"
                   FromPort: 3306
                   ToPort: 3306
                   SourceSecurityGroupId: !GetAtt ApplicationSG.GroupId           
            VpcId: !Ref VPC
        ...

Create the CloudFormation stack via AWS cli:

    export DEFAULT_VPC_ID="vpc-c2..." #your vpc id 
    export SUBNET_IDS="subnet-4e...,subnet-40...,subnet-57..." #your subnet ids

    aws cloudformation create-stack \
        --stack-name samplewebworkload-net-dev \
        --template-body file://network-cf.yaml \
        --parameters ParameterKey=Subnets,ParameterValue=\"$SUBNET_IDS\" \
                     ParameterKey=VPC,ParameterValue=$DEFAULT_VPC_ID

## Load Balancer

![Load Balancer](drawio/loadbalancer.png)
 
Requirements:
- Load balancer must be reachable via a custom domain name
- Load balancer must terminate HTTPS traffic
- Load balancer must forward traffic to our application via HTTP

A properly configured Application Load Balancer meets the requirements:
- TLSListeer: terminates HTTPS traffic and is associated with a previosly created AWS Certificate Manager TLS certificate
- TargetGroup: forwards all traffic to the application via HTTP
- A Route53 CNAME record can refer the CNAME of the Application Load Balancer in a subsequent step

CloudFormation yaml template (some details omitted):

    ...
    Resources:
        TargetGroup:
            Type: AWS::ElasticLoadBalancingV2::TargetGroup
            Properties:
                HealthCheckIntervalSeconds: 30
                HealthCheckPath: /
                HealthCheckTimeoutSeconds: 5
                UnhealthyThresholdCount: 4
                HealthyThresholdCount: 2
                Port: 8080
                Protocol: HTTP
                TargetGroupAttributes:
                    - Key: deregistration_delay.timeout_seconds
                      Value: 60 
                TargetType: ip
                VpcId: !Ref VPC

        TLSListener:
            Type: AWS::ElasticLoadBalancingV2::Listener
            Condition: EnableTLS
            Properties:
                Certificates: 
                    - CertificateArn: !Ref CertificateArn
                DefaultActions:
                    - TargetGroupArn: !Ref TargetGroup
                      Type: forward
                LoadBalancerArn: !Ref LoadBalancer
                Port: 443
                Protocol: HTTPS

        LoadBalancer:
            Type: AWS::ElasticLoadBalancingV2::LoadBalancer
            Properties:
                LoadBalancerAttributes:
                    - Key: idle_timeout.timeout_seconds
                      Value: 60
                Scheme: internet-facing
                SecurityGroups:
                    - !Ref SecurityGroup
                Subnets: !Ref Subnets
        ...

Create the CloudFormation stack via AWS cli:

    export SG_ID="sg-12..." #your security group id
    export DEFAULT_VPC_ID="vpc-c2..." #your vpc id 
    export SUBNET_IDS="subnet-4e...,subnet-40...,subnet-57..." #your subnet ids
    export SSL_CERT_ARN="arn:aws:acm:eu-west-1:20...:certificate/73..." #your ACM cert ARN

    aws cloudformation create-stack \
        --stack-name samplewebworkload-lb-dev \
        --template-body file://lb-cf.yaml \
        --parameters ParameterKey=Subnets,ParameterValue=\"$SUBNET_IDS\" \
                     ParameterKey=VPC,ParameterValue=$DEFAULT_VPC_ID \
                     ParameterKey=SecurityGroup,ParameterValue=$SG_ID \
                     ParameterKey=CertificateArn,ParameterValue="$SSL_CERT_ARN"

## Database

![Load Balancer](drawio/database.png)
 
Requirements: Managed MySQL database

An Amazon RDS for MySQL database instance meets the requirements.

CloudFormation yaml template (some details omitted):

    ...
    Resources:
        DBSubnetGroup:
            Type: "AWS::RDS::DBSubnetGroup"
            Properties: 
                DBSubnetGroupDescription: db subnet group
                SubnetIds: !Ref Subnets

        DB:
            Type: AWS::RDS::DBInstance
            Properties:
                DBSubnetGroupName: !Ref DBSubnetGroup
                DBName: db
                VPCSecurityGroups:
                    - Ref: SecurityGroup
                AllocatedStorage: '5'
                DBInstanceClass: db.t3.micro
                Engine: MySQL
                MasterUsername: masteruser
                MasterUserPassword: !Ref MasterUserPassword
                DeletionPolicy: Delete
        ...

Create the CloudFormation stack via AWS cli:

    export SG_ID="sg-34..." #your security group id
    export DEFAULT_VPC_ID="vpc-c20263a4" #your vpc id 
    export SUBNET_IDS="subnet-4e...,subnet-40...,subnet-57..." #your subnet ids
    export DB_KEY="..." #your secret key

    aws cloudformation create-stack \
        --stack-name samplewebworkload-db-dev \
        --template-body file://db-cf.yaml \
        --parameters ParameterKey=Subnets,ParameterValue=\"$SUBNET_IDS\" \
                     ParameterKey=SecurityGroup,ParameterValue=$SG_ID \
                     ParameterKey=MasterUserPassword,ParameterValue=$DB_KEY

## Privte Docker Registry

![Private Docker Registry](drawio/deployment.png)
 
Requirements: a private docker registry

An Elastic Container Registry meets the requirements.

CloudFormation yaml template (some details omitted):

    ...
    Resources:
        DockerRepo:
            Type: AWS::ECR::Repository
            Properties: 
                RepositoryName: !Ref 'AWS::StackName'
        ...

Create the CloudFormation stack via AWS cli:

    aws cloudformation create-stack \
        --stack-name samplewebworkload-repo-dev \
        --template-body file://repo-cf.yaml

## Application

Requirements:
- Run dockerized Spring Boot web application
- No hard-coded environment specific configuratiomn (DB host & port)
- No passwords in configuration files or environment variables (DB password)
- Centralized logging
- Easy redeployment

The following services (in concert) meet these requirements:
- Run docker containers via AWS Fargate (as a service with one task with one container)
- Force redeployment (via API/AWS cli) after docker push to roll out a new version
- Logging to CloudWatch (Fargate configuration)
- Configuration via environment variables (DB host & port)
- DB password is stored in AWS Systems Manager Parameter Store as secure string

CloudFormation yaml template (some details omitted):

    ...
    Resources:
        # Required for CloudWatch logging, amongst others
        ECSExecutionRole:
            Type: AWS::IAM::Role
            Properties:
                AssumeRolePolicyDocument:
                    Version: "2012-10-17"
                    Statement:
                        - Effect: "Allow"
                          Principal:
                            Service:
                                - "ecs-tasks.amazonaws.com"
                          Action:
                            - "sts:AssumeRole"
                ManagedPolicyArns:
                    - "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
                MaxSessionDuration: 3600
                Path: /service-role/

        # Required to read secure strings in AWS Systems Manager Parameter Store
        TaskRole:
            Type: AWS::IAM::Role
            Properties:
                AssumeRolePolicyDocument:
                    Version: "2012-10-17"
                    Statement:
                        - Effect: "Allow"
                          Principal:
                            Service:
                                - "ecs-tasks.amazonaws.com"
                          Action:
                            - "sts:AssumeRole"
                Policies:
                    - PolicyName: !Sub 'TaskRole-${AWS::StackName}'
                      PolicyDocument:
                            Version: 2012-10-17
                            Statement:
                                - Effect: Allow
                            Action:
                                - 'ssm:GetParameter'
                            Resource:
                                - !Sub "arn:aws:ssm:${AWS::Region}:${AWS::AccountId}:parameter/${DBPassSSMName}"
                MaxSessionDuration: 3600
                Path: /service-role/

        # Required to read from AWS Systems Manager Parameter Store
        TaskLogGroup:
            Type: AWS::Logs::LogGroup
            Properties: 
                LogGroupName: !Join [ '', [ '/ecs/', !Ref 'AWS::StackName' ] ]
                RetentionInDays: 7

        # Spring Boot app task definition (ref to :latest image simple deployment in dev) and env-specific configuration
        TaskDefinition:
            Type: AWS::ECS::TaskDefinition
            Properties: 
                ExecutionRoleArn: !GetAtt ECSExecutionRole.Arn
                TaskRoleArn: !GetAtt TaskRole.Arn
                Cpu: "1024"
                Memory: "2048"
                Family: !Ref 'AWS::StackName'
                NetworkMode: "awsvpc"
                RequiresCompatibilities:
                    - "FARGATE"
                ContainerDefinitions:
                    - Cpu: "256"
                      Essential: true
                      Image: !Sub "${AWS::AccountId}.dkr.ecr.${AWS::Region}.amazonaws.com/${DockerRepo}:latest"
                      LogConfiguration:
                        LogDriver: "awslogs"
                        Options:
                            "awslogs-group": !Ref TaskLogGroup
                            "awslogs-region": !Ref 'AWS::Region'
                            "awslogs-stream-prefix": "ecs"
                      Memory: "512"
                      MemoryReservation: "512"
                      Name: !Ref 'AWS::StackName'
                      PortMappings:
                        - ContainerPort: 8080
                          Protocol: "tcp"
                      Environment:
                        - Name: DBPort
                          Value: !Ref DBPort 
                        - Name: DBAddress
                          Value: !Ref DBAddress 
                        - Name: DBPassSSMName
                          Value: !Ref DBPassSSMName

        FargateCluster:
            Type: AWS::ECS::Cluster

        # Running service (with one task with one Spring Boot app container)
        FargateService:
            Type: AWS::ECS::Service
            Properties: 
                Cluster: !Ref FargateCluster
                DeploymentConfiguration:
                    MaximumPercent: 200
                    MinimumHealthyPercent: 100
                DesiredCount: 1
                LaunchType: "FARGATE"
                NetworkConfiguration: 
                    AwsvpcConfiguration: 
                    AssignPublicIp: "ENABLED"
                    SecurityGroups: 
                        - !Ref SecurityGroup
                    Subnets: !Ref Subnets
                PlatformVersion: "LATEST"
                SchedulingStrategy: "REPLICA"
                TaskDefinition: !Ref TaskDefinition
                LoadBalancers:
                    - ContainerName: !Ref 'AWS::StackName'
                      ContainerPort: 8080
                      TargetGroupArn: !Ref TargetGroup
        ...

Create the CloudFormation stack via AWS cli:



# Spring Boot and AWS Fargate (in 13' from 0 to cloud)

## Pre-Conditions

- AWS cli installed & configured (sufficient IAM permissions, default region)
- Default VPC present in default AWS region
- Docker running
- Linux-like environment (bash, curl, sed, ...)
- openssl installed
- jq installed
- ...

## Setup development environment (ECR + ALB + Fargate Service + RDS)

Disclaimer:
- Not production ready yet (e.g. automation scripts w/o error handling)
- Setup duration: approx. 13'
- Costs (until teardown): approx. 75 USD/month

Steps:

    ./setup-dev.sh

Verify:

    ./curl-loop-dev.sh

## Deploy new application version

Steps:

    ./update-dev.sh

## Teardown development environment

Disclaimer:
- Not production ready yet (e.g. automation scripts w/o error handling)

Steps:

    ./teardown-dev.sh

# AWS Infrastructure Details

![Infrastructure Details](drawio/alb-fargate-rds-ssm.png)
