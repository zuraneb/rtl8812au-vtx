#!/bin/bash

MODULE_NAME="88XXau_ohd"  # Set your kernel module name

PARAM_DIR="/sys/module/$MODULE_NAME/parameters"

# Check if the directory exists
if [ ! -d "$PARAM_DIR" ]; then
  echo "Module parameters directory not found: $PARAM_DIR"
  exit 1
fi

# Loop through each parameter file in the module's parameter directory
for param in "$PARAM_DIR"/*; do
  # Get the parameter name (file name)
  param_name=$(basename "$param")
  
  # Read the parameter value
  param_value=$(cat "$param")
  
  # Print the parameter name and value
  echo "Parameter: $param_name, Value: $param_value"
done
