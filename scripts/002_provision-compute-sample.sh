#!/bin/bash

# Variable containing AWS profile to be used 
# for deploying cloud formation stack.
PROFILE_NAME="";

#==================================================================================
# Non-Required variable names here...
#==================================================================================

TEMPLATE_STORE_STACK_NAME="template-store-stack";
ECS_CLUSTER_COMPUTE_STACK_NAME="ecs-cluster-stack";

if [ -z "$PROFILE_NAME" ]
then
  echo "Please set the value of PROFILE_NAME variable inside the script."
  echo "Press any key to exit...."
  read
  exit 0
fi

S3_TEMPLATE_STORE_NAME=$(aws cloudformation describe-stacks --profile "${PROFILE_NAME}" --stack-name "${TEMPLATE_STORE_STACK_NAME}" --query "Stacks[0].Outputs[?OutputKey=='TemplateStorageBucketName'].OutputValue" --output text); 

if aws cloudformation describe-stacks --profile "$PROFILE_NAME" --stack-name "$ECS_CLUSTER_COMPUTE_STACK_NAME" &> /dev/null ; then
  echo "Updating ECS compute cluster exists...";
  aws cloudformation update-stack \
    --profile "${PROFILE_NAME}" \
    --stack-name "${ECS_CLUSTER_COMPUTE_STACK_NAME}" \
    --template-body file://infrastructure/root-stack.yaml  \
    --parameters ParameterKey=TemplateS3BucketUrl,ParameterValue="https://s3.amazonaws.com/${S3_TEMPLATE_STORE_NAME}" \
    --capabilities CAPABILITY_NAMED_IAM

  echo "Waiting template store stack to be updated.."
  aws cloudformation wait stack-update-complete \
    --profile "${PROFILE_NAME}" \
    --stack-name "${ECS_CLUSTER_COMPUTE_STACK_NAME}"

  echo "ECS compute cluster updated...";
else
  echo "Creating ECS compute cluster exists...";
  aws cloudformation create-stack \
    --profile "${PROFILE_NAME}" \
    --stack-name "${ECS_CLUSTER_COMPUTE_STACK_NAME}" \
    --template-body file://infrastructure/root-stack.yaml  \
    --parameters ParameterKey=TemplateS3BucketUrl,ParameterValue="https://s3.amazonaws.com/${S3_TEMPLATE_STORE_NAME}" \
    --capabilities CAPABILITY_NAMED_IAM

  echo "Waiting template store stack to be created.."
  aws cloudformation wait stack-create-complete \
    --profile "${PROFILE_NAME}" \
    --stack-name "${ECS_CLUSTER_COMPUTE_STACK_NAME}"

  echo "ECS compute cluster created...";
fi

echo "================================================"
echo "Press any key to exit..."
echo "================================================"

# If you are debugging, uncomment read command below
read