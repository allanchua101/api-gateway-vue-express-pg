#!/bin/bash
echo "Running frontend linters"

cd ../../frontend/

ERRORS=$(npm run lint 2>&1 >/dev/null)

if [ "$?" -gt "0" ];
then
  echo ""
  echo ""
  echo "Linting errors found:"
  echo ""
  echo "$ERRORS"
  echo ""
  exit 1; 
else
  echo ""
  echo ""
  echo "No linting errors found..."
  echo ""
  echo ""
fi;

# Uncomment this line if you want to exit
# read -p "Press any key to exit..." exit_key