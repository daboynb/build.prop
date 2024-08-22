#!/bin/sh

# Display help
case "$1" in
  -h|--help|help)
    echo "sh append_fields.sh [json-file]"
    exit 0
    ;;
esac

# Check if the input file exists
if [ ! -f "$1" ]; then
  echo "Error: No valid JSON file provided."
  echo "Usage: sh append_fields.sh [json-file]"
  exit 1
fi

JSON_FILE="$1"

# Define new fields with their values
spoofBuild=true
spoofBuildZygisk=true
spoofProps=true
spoofProvider=true
spoofSignature=false

# Backup the original JSON file
cp "$JSON_FILE" "$JSON_FILE.bak"

# Append new fields to the JSON
echo "Appending fields to $JSON_FILE ..."

# Add the new fields at the end of the JSON object
jq ". + {
  \"spoofBuild\": $spoofBuild,
  \"spoofBuildZygisk\": $spoofBuildZygisk,
  \"spoofProps\": $spoofProps,
  \"spoofProvider\": $spoofProvider,
  \"spoofSignature\": $spoofSignature
}" "$JSON_FILE" > "${JSON_FILE}.tmp" && mv "${JSON_FILE}.tmp" "$JSON_FILE"

echo "Fields appended successfully. Backup saved as $JSON_FILE.bak"

# Display the modified JSON file
cat "$JSON_FILE"
