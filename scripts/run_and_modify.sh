#!/bin/bash

# Usage: ./run_and_modify.sh "parameter"

# Check for required argument
if [ -z "$1" ]; then
  echo "Usage: $0 <modification_text>"
  exit 1
fi

PARAM="$1"

# Run the Python script and capture its output
OUTPUT=$(python3 "$(dirname "$0")/../hello_world.py")

# Modify the output using the parameter
MODIFIED_OUTPUT="${OUTPUT} | Modified with: ${PARAM}"

# Display modified output
echo "$MODIFIED_OUTPUT"