#!/bin/bash

# Variable containing AWS profile to be used 
# for deploying cloud formation stack.
PROFILE_NAME="";

# Variable containing S3 bucket name to be used
# as a storage for your cloud formation templates.
TEMPLATE_STORE_BUCKET_NAME="";

# Variable containing name of ECRs.
BACKEND_ECR_NAME="";
FRONTEND_ECR_NAME="";
GATEWAY_ECR_NAME="";

#==================================================================================
# Non-Required variable names here...
#==================================================================================

TEMPLATE_STORE_STACK_NAME="template-store-stack";
ECR_STACK_NAME="ecr-stack";
INFRASTRUCTURE_FILES=./infrastructure/*.yaml
PIPELINE_FILES=./pipeline/*.yaml

if [ -z "$PROFILE_NAME" ]
then
  echo "Please set the value of PROFILE_NAME variable inside the script."
  echo "Press any key to exit...."
  read
  exit 0
fi

if [ -z "$TEMPLATE_STORE_BUCKET_NAME" ]
then
  echo "Please set the value of TEMPLATE_STORE_BUCKET_NAME variable inside the script."
  echo "Press any key to exit...."
  read
  exit 0
fi

if [ -z "$BACKEND_ECR_NAME" ]
then
  echo "Please set the value of BACKEND_ECR_NAME variable inside the script."
  echo "Press any key to exit...."
  read
  exit 0
fi

if [ -z "$FRONTEND_ECR_NAME" ]
then
  echo "Please set the value of FRONTEND_ECR_NAME variable inside the script."
  echo "Press any key to exit...."
  read
  exit 0
fi

if [ -z "$GATEWAY_ECR_NAME" ]
then
  echo "Please set the value of GATEWAY_ECR_NAME variable inside the script."
  echo "Press any key to exit...."
  read
  exit 0
fi

# Ensure template storage exists.
if ! aws cloudformation describe-stacks --profile "$PROFILE_NAME" --stack-name "$TEMPLATE_STORE_STACK_NAME" &> /dev/null ; then
  echo "Creating template store stack.."
  aws cloudformation create-stack \
    --profile "${PROFILE_NAME}" \
    --stack-name "${TEMPLATE_STORE_STACK_NAME}" \
    --template-body file://pipeline/build-s3.yaml \
    --parameters ParameterKey=BucketName,ParameterValue="${TEMPLATE_STORE_BUCKET_NAME}" &> /dev/null

  echo "Waiting template store stack to be created.."
  aws cloudformation wait stack-create-complete \
    --profile "${PROFILE_NAME}" \
    --stack-name "${TEMPLATE_STORE_STACK_NAME}"

  echo "Template store stack created..."
else
  echo "Template store stack exists..."
fi

echo "================================================"
echo "Uploading base infrastructure files...."
echo "================================================"
for f in $INFRASTRUCTURE_FILES
do
  echo "Uploading $f file..."
  aws s3 cp $f "s3://${TEMPLATE_STORE_BUCKET_NAME}/${f/.\//$''}" --profile "${PROFILE_NAME}" &> /dev/null
done

echo "================================================"
echo "Uploading base pipeline-related files...."
echo "================================================"
for f in $PIPELINE_FILES
do
  echo "Uploading $f file..."
  aws s3 cp $f "s3://${TEMPLATE_STORE_BUCKET_NAME}/${f/.\//$''}" --profile "${PROFILE_NAME}" &> /dev/null
done
echo "================================================"

if ! aws cloudformation describe-stacks --profile "$PROFILE_NAME" --stack-name "$ECR_STACK_NAME" &> /dev/null ; then
  echo "Creating ECR cloudformation stack.."
  aws cloudformation create-stack \
    --profile "${PROFILE_NAME}" \
    --stack-name "${ECR_STACK_NAME}" \
    --template-body file://pipeline/ecr.yaml \
    --parameters ParameterKey=BackendEcrName,ParameterValue="${BACKEND_ECR_NAME}" \
    ParameterKey=FrontendEcrName,ParameterValue="${FRONTEND_ECR_NAME}" \
    ParameterKey=GatewayEcrName,ParameterValue="${GATEWAY_ECR_NAME}"

  echo "Waiting ECR cloudformation stack.."
  aws cloudformation wait stack-create-complete \
    --profile "${PROFILE_NAME}" \
    --stack-name "${ECR_STACK_NAME}"

  echo "ECR Cloudformation stack created..."
else
  echo "ECR Cloudformation already exists..."
fi

echo "================================================"
echo "Press any key to exit..."
echo "================================================"

# If you are debugging, uncomment read command below
read