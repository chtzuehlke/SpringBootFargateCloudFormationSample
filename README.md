# Let's play with Spring Boot and AWS Fargate

![High Level Overview](drawio/overview.png)

Target Architecture:
- Load balancer: Application Load Balancer (with TLS-termination)
- Web application: containerized Java (Spring Boot-) application running as a AWS Fargate service
- Database: Amazon RDS for MySQL instance
- As old and new versions will have DB access at the same time during deployment, DB changes must be backwards-compatible and applications must be forwards- and backwards-compatible (e.g. add columns, not delete or rename columns)

## All automated - from zero to cloud in 13'

### Pre-Conditions

- AWS cli installed & configured (sufficient IAM permissions, default region configured)
- Default VPC is present in the default AWS region
- Docker is running
- Linux-like environment or macOS (bash, curl, sed, ...) 
- openssl installed
- jq installed
- General advice: read - and understand - all shell scripts and CloudFormation yaml templates before executing them

### Automated dev env setup (ECR + ALB + Fargate Service + RDS)

Disclaimer:
- Not production ready yet (e.g. automation scripts w/o error handling)
- Costs (until teardown): approx. 75 USD/month

Steps:

    ./setup-dev.sh
    ./curl-loop-dev.sh

### Deploy new application version

Steps:

    ./update-dev.sh

### Automated dev env teardown (delete all stacks/resources)

Disclaimer:
- Not production ready yet (e.g. automation scripts w/o error handling)
- All data lost!

 Steps:

    ./teardown-dev.sh

## Behind the scenes (CloudFormation and AWS cli)

### Network Security

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

    DEFAULT_VPC_ID=$(aws ec2 describe-vpcs --query 'Vpcs[?IsDefault==`true`].VpcId' --output text)
    SUBNET_IDS=$(aws ec2 describe-subnets --query "Subnets[?VpcId==\`$DEFAULT_VPC_ID\`].SubnetId" --output text | sed 's/[[:space:]]/,/g')

    aws cloudformation create-stack \
        --stack-name samplewebworkload-net-dev \
        --template-body file://network-cf.yaml \
        --parameters ParameterKey=Subnets,ParameterValue=\"$SUBNET_IDS\" \
                     ParameterKey=VPC,ParameterValue=$DEFAULT_VPC_ID

### Load Balancer

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
                VpcId: 
                    "Fn::ImportValue": !Sub "${NetworkStack}-VPC"

        TLSListener:
            Type: AWS::ElasticLoadBalancingV2::Listener
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
                    - "Fn::ImportValue": !Sub "${NetworkStack}-LoadBalancerSG"
                Subnets: !Split [ ",", "Fn::ImportValue": !Sub "${NetworkStack}-Subnets" ]
        ...

Create the CloudFormation stack via AWS cli:

    SSL_CERT_ARN="arn:aws:acm:eu-west-1:20...:certificate/73..." #your ACM cert ARN

    aws cloudformation create-stack \
        --stack-name samplewebworkload-lb-dev \
        --template-body file://lb-cf.yaml \
        --parameters ParameterKey=CertificateArn,ParameterValue="$SSL_CERT_ARN" \
                     ParameterKey=NetworkStack,ParameterValue=samplewebworkload-net-dev

### Database

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
                SubnetIds: !Split [ ",", "Fn::ImportValue": !Sub "${NetworkStack}-Subnets" ]

        DB:
            Type: AWS::RDS::DBInstance
            Properties:
                DBSubnetGroupName: !Ref DBSubnetGroup
                DBName: db
                VPCSecurityGroups:
                    - "Fn::ImportValue": !Sub "${NetworkStack}-DatabaseSG"
                AllocatedStorage: '5'
                DBInstanceClass: db.t3.micro
                Engine: MySQL
                MasterUsername: masteruser
                MasterUserPassword: !Ref MasterUserPassword
                DeletionPolicy: Delete
        ...

Create the CloudFormation stack (and a random password in SSM parameter store) via AWS cli:

    PASS=$(openssl rand -hex 20)
    DB_PASSWORD_PARAM_NAME="dev.db.rand.pass"
    aws ssm put-parameter --overwrite --name $DB_PASSWORD_PARAM_NAME --type SecureString --value "$PASS"

    aws cloudformation create-stack \
        --stack-name samplewebworkload-db-dev \
        --template-body file://db-cf.yaml \
        --parameters ParameterKey=MasterUserPassword,ParameterValue=$PASS
                     ParameterKey=NetworkStack,ParameterValue=samplewebworkload-net-dev

### Privte Docker Registry

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

Build and push docker image:

    ./mvnw clean install dockerfile:build

    LOCAL_TAG=chtzuehlke/sample-web-workload:latest
    
    STACK="samplewebworkload-repo-dev"
    OUTPUT="DockerRepoUrl"
    REMOTE_TAG=$(aws cloudformation describe-stacks --stack-name $STACK --query "Stacks[0].Outputs[?OutputKey=='$OUTPUT'].OutputValue" --output text)
    
    docker tag $LOCAL_TAG $REMOTE_TAG

    $(aws ecr get-login --no-include-email)    
    docker push $REMOTE_TAG

### Spring Boot Application

Requirements:
- Run dockerized Spring Boot web application
- No hard-coded environment-specific configuration (DB host & port)
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

        TaskLogGroup:
            Type: AWS::Logs::LogGroup
            Properties: 
                LogGroupName: !Join [ '', [ '/ecs/', !Ref 'AWS::StackName' ] ]
                RetentionInDays: 7

        # Spring Boot app task definition & configuration (:latest for simple deployment in dev)
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
                      Image: !Join [ "", [ !Ref "AWS::AccountId", ".dkr.ecr.", !Ref "AWS::Region", ".amazonaws.com/", "Fn::ImportValue": !Sub "${DockerRepoStack}-DockerRepo", ":latest" ] ]
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
                          Value: 
                            "Fn::ImportValue": 
                                !Sub "${DatabaseStack}-DBPort" 
                        - Name: DBAddress
                          Value:
                            "Fn::ImportValue": 
                                !Sub "${DatabaseStack}-DBAddress"
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
                        - "Fn::ImportValue": !Sub "${NetworkStack}-ApplicationSG"
                    Subnets: !Split [ ",", "Fn::ImportValue": !Sub "${NetworkStack}-Subnets" ]
                PlatformVersion: "LATEST"
                SchedulingStrategy: "REPLICA"
                TaskDefinition: !Ref TaskDefinition
                LoadBalancers:
                    - ContainerName: !Ref 'AWS::StackName'
                      ContainerPort: 8080
                      TargetGroupArn:
                        "Fn::ImportValue": 
                            !Sub "${LoadBalancerStack}-TargetGroup" 
        ...

Create the CloudFormation stack via AWS cli:

    DB_PASSWORD_PARAM_NAME="dev.db.rand.pass"

    aws cloudformation create-stack \
        --capabilities CAPABILITY_IAM \
        --stack-name samplewebworkload-fargatew-dev \
        --template-body file://fargate-cf.yaml \
        --parameters ParameterKey=NetworkStack,ParameterValue=samplewebworkload-net-dev \
                     ParameterKey=LoadBalancerStack,ParameterValue=samplewebworkload-lb-dev \
                     ParameterKey=DatabaseStack,ParameterValue=samplewebworkload-db-dev \
                     ParameterKey=DockerRepoStack,ParameterValue=samplewebworkload-repo-dev \
                     ParameterKey=DBPassSSMName,ParameterValue=$DB_PASSWORD_PARAM_NAME

Force redeployment after docker push:

    STACK="samplewebworkload-fargatew-dev"
    OUTPUT="FargateCluster"
    CLUSTER=$(aws cloudformation describe-stacks --stack-name $STACK --query "Stacks[0].Outputs[?OutputKey=='$OUTPUT'].OutputValue" --output text)

    OUTPUT="FargateService"
    SERVICE=$(aws cloudformation describe-stacks --stack-name $STACK --query "Stacks[0].Outputs[?OutputKey=='$OUTPUT'].OutputValue" --output text)

    aws ecs update-service --cluster $CLUSTER --service $SERVICE --force-new-deployment

## AWS Infrastructure

![Infrastructure Details](drawio/alb-fargate-rds-ssm.png)
