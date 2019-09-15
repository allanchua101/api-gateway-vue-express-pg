#!/bin/bash

# Variable containing AWS profile to be used 
# for deploying cloud formation stack.
PROFILE_NAME="";

# Variable containing S3 bucket name to be used
# as a storage for your cloud formation templates.
TEMPLATE_STORE_BUCKET_NAME="";

# Variable containing name of ECR.
ECR_NAME="";

# Variable containing the name of your cloudformation
# stack name.
TEMPLATE_STORE_STACK_NAME="template-store-stack";

# Variable containing name of ECR.
ECR_STACK_NAME="ecr-stack";

# Variable containing path of infrastructure CF templates.
INFRASTRUCTURE_FILES=./infrastructure/*.yaml

# Variable containing path of pipeline CF templates.
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

if [ -z "$ECR_NAME" ]
then
  echo "Please set the value of ECR_NAME variable inside the script."
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

# Ensure template storage exists.
if ! aws cloudformation describe-stacks --profile "$PROFILE_NAME" --stack-name "$ECR_STACK_NAME" &> /dev/null ; then
  echo "Creating ECR cloudformation stack.."
  aws cloudformation create-stack \
    --profile "${PROFILE_NAME}" \
    --stack-name "${ECR_STACK_NAME}" \
    --template-body file://pipeline/ecr.yaml \
    --parameters ParameterKey=EcrName,ParameterValue="${ECR_NAME}" &> /dev/null

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