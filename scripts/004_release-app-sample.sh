#!/bin/bash

# Variable containing AWS profile to be used 
# for deploying cloud formation stack.
PROFILE_NAME="";

#==================================================================================
# Non-Required variable names here...
#==================================================================================

TEMPLATE_STORE_STACK_NAME="template-store-stack";
ECS_SERVICE_AND_TASK_STACK="ecs-task-and-service";
ECR_STACK_NAME="ecr-stack";
SERVICE_FILES=./services/*.yaml

if [ -z "$PROFILE_NAME" ]
then
  echo "Please set the value of PROFILE_NAME variable inside the script."
  echo "Press any key to exit...."
  read
  exit 0
fi

S3_TEMPLATE_STORE_NAME=$(aws cloudformation describe-stacks --profile "${PROFILE_NAME}" --stack-name "${TEMPLATE_STORE_STACK_NAME}" --query "Stacks[0].Outputs[?OutputKey=='TemplateStorageBucketName'].OutputValue" --output text); 

# Backend
BACKEND_ECR_NAME=$(aws cloudformation describe-stacks --profile "${PROFILE_NAME}" --stack-name "${ECR_STACK_NAME}" --query "Stacks[0].Outputs[?OutputKey=='BackendEcrName'].OutputValue" --output text); 
BACKEND_ECR_URI=$(aws ecr describe-repositories --repository-name ${BACKEND_ECR_NAME} --profile ${PROFILE_NAME} --query "repositories[0].repositoryUri" --output text); 

# Frontend
FRONTEND_ECR_NAME=$(aws cloudformation describe-stacks --profile "${PROFILE_NAME}" --stack-name "${ECR_STACK_NAME}" --query "Stacks[0].Outputs[?OutputKey=='FrontendEcrName'].OutputValue" --output text); 
FRONTEND_ECR_URI=$(aws ecr describe-repositories --repository-name ${FRONTEND_ECR_NAME} --profile ${PROFILE_NAME} --query "repositories[0].repositoryUri" --output text); 

# API Gateway
GATEWAY_ECR_NAME=$(aws cloudformation describe-stacks --profile "${PROFILE_NAME}" --stack-name "${ECR_STACK_NAME}" --query "Stacks[0].Outputs[?OutputKey=='GatewayEcrName'].OutputValue" --output text); 
GATEWAY_ECR_URI=$(aws ecr describe-repositories --repository-name ${GATEWAY_ECR_NAME} --profile ${PROFILE_NAME} --query "repositories[0].repositoryUri" --output text); 

echo "================================================"
echo "Uploading base service files...."
echo "================================================"
for f in $SERVICE_FILES
do
  echo "Uploading $f file..."
  aws s3 cp $f "s3://${S3_TEMPLATE_STORE_NAME}/${f/.\//$''}" --profile "${PROFILE_NAME}" &> /dev/null
done

if aws cloudformation describe-stacks --profile "$PROFILE_NAME" --stack-name "$ECS_SERVICE_AND_TASK_STACK" &> /dev/null ; then
  echo "Updating ECS services and tasks..";
  aws cloudformation update-stack \
    --profile "${PROFILE_NAME}" \
    --stack-name "${ECS_SERVICE_AND_TASK_STACK}" \
    --template-body file://services/service-bundle.yaml  \
    --parameters ParameterKey=TemplateS3BucketUrl,ParameterValue="https://s3.amazonaws.com/${S3_TEMPLATE_STORE_NAME}" \
    ParameterKey=BackendImageUri,ParameterValue="${BACKEND_ECR_URI}:latest" \
    ParameterKey=FrontendImageUri,ParameterValue="${FRONTEND_ECR_URI}:latest" \
    --capabilities CAPABILITY_NAMED_IAM

  echo "Waiting for ECS service and task updates..";
  aws cloudformation wait stack-update-complete \
    --profile "${PROFILE_NAME}" \
    --stack-name "${ECS_SERVICE_AND_TASK_STACK}"

  echo "ECS service and task complete..";
else
  echo "Creating ECS services and tasks..";
  aws cloudformation create-stack \
    --profile "${PROFILE_NAME}" \
    --stack-name "${ECS_SERVICE_AND_TASK_STACK}" \
    --template-body file://services/service-bundle.yaml  \
    --parameters ParameterKey=TemplateS3BucketUrl,ParameterValue="https://s3.amazonaws.com/${S3_TEMPLATE_STORE_NAME}" \
    ParameterKey=BackendImageUri,ParameterValue="${BACKEND_ECR_URI}:latest" \
    ParameterKey=FrontendImageUri,ParameterValue="${FRONTEND_ECR_URI}:latest" \
    --capabilities CAPABILITY_NAMED_IAM

  echo "Waiting for ECS service and task creation..";
  aws cloudformation wait stack-create-complete \
    --profile "${PROFILE_NAME}" \
    --stack-name "${ECS_SERVICE_AND_TASK_STACK}"

  echo "ECS service and task creation complete..";
fi

echo "================================================"
echo "Press any key to exit..."
echo "================================================"

# If you are debugging, uncomment read command below
read