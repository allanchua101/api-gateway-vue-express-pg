#!/bin/bash

# Variable containing AWS profile to be used 
# for deploying cloud formation stack.
PROFILE_NAME="";

ECR_STACK_NAME="ecr-stack";

if [ -z "$PROFILE_NAME" ]
then
  echo "Please set the value of PROFILE_NAME variable inside the script."
  echo "Press any key to exit...."
  read
  exit 0
fi

# Backend
BACKEND_ECR_NAME=$(aws cloudformation describe-stacks --profile "${PROFILE_NAME}" --stack-name "${ECR_STACK_NAME}" --query "Stacks[0].Outputs[?OutputKey=='BackendEcrName'].OutputValue" --output text); 
BACKEND_ECR_URI=$(aws ecr describe-repositories --repository-name ${BACKEND_ECR_NAME} --profile ${PROFILE_NAME} --query "repositories[0].repositoryUri" --output text); 

# Frontend
FRONTEND_ECR_NAME=$(aws cloudformation describe-stacks --profile "${PROFILE_NAME}" --stack-name "${ECR_STACK_NAME}" --query "Stacks[0].Outputs[?OutputKey=='FrontendEcrName'].OutputValue" --output text); 
FRONTEND_ECR_URI=$(aws ecr describe-repositories --repository-name ${FRONTEND_ECR_NAME} --profile ${PROFILE_NAME} --query "repositories[0].repositoryUri" --output text); 

# API Gateway
GATEWAY_ECR_NAME=$(aws cloudformation describe-stacks --profile "${PROFILE_NAME}" --stack-name "${ECR_STACK_NAME}" --query "Stacks[0].Outputs[?OutputKey=='GatewayEcrName'].OutputValue" --output text); 
GATEWAY_ECR_URI=$(aws ecr describe-repositories --repository-name ${GATEWAY_ECR_NAME} --profile ${PROFILE_NAME} --query "repositories[0].repositoryUri" --output text); 

# Login to ECR
eval $(aws ecr get-login --no-include-email --region ap-southeast-1 --profile ${PROFILE_NAME})


docker build -t "${BACKEND_ECR_URI}:latest" ../backend
docker push "${BACKEND_ECR_URI}:latest"

docker build -t "${FRONTEND_ECR_URI}:latest" ../frontend
docker push "${FRONTEND_ECR_URI}:latest"

docker build -t "${GATEWAY_ECR_URI}:latest" ../gateway/WebGateway
docker push "${GATEWAY_ECR_URI}:latest"

echo "================================================"
echo "Press any key to exit..."
echo "================================================"

read;