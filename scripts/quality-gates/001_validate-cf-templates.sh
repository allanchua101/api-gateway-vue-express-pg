#!/bin/bash
ERROR_COUNT=0;
PROFILE_NAME=$1;

if [ -z "$PROFILE_NAME" ]
then
      echo "\$PROFILE_NAME is empty! Stopping console in 3 seconds.."
      echo ""
      echo ""
      read -p "Press any key to exit...." key
      exit 1;
else
      echo "Validating templates using profile named $PROFILE_NAME"
      echo ""
      echo ""
fi

echo "Validating AWS CloudFormation templates..."
echo ""
echo ""

# Loop through the YAML templates in the infrastructure folder.
for TEMPLATE in $(find ../infrastructure -name '*.yaml'); do 
    # Validate the template with CloudFormation
    ERRORS=$(aws cloudformation validate-template --profile $PROFILE_NAME --template-body file://$TEMPLATE 2>&1 >/dev/null); 
    if [ "$?" -gt "0" ]; then 
        ((ERROR_COUNT++));
        echo "[fail] $TEMPLATE: $ERRORS";
    else 
        echo "[pass] $TEMPLATE";
    fi; 
    
done; 

echo "$ERROR_COUNT template validation error(s)"; 
echo ""
echo ""

# Uncomment this line if you want to exit
# read -p "Press any key to exit..." exitkey

if [ "$ERROR_COUNT" -gt 0 ]; 
    then exit 1; 
fi