#!/bin/bash

# Check if required arguments are provided
if [ $# -ne 3 ]; then
  echo "Usage: $0 <workflow_name> <repo> <date_range>"
  echo "Example: $0 'ci.yml' 'org/repo' '2025-03-14..2025-03-15'"
  exit 1
fi

WORKFLOW_NAME=$1
REPO=$2
DATE_RANGE=$3

echo "Listing workflow runs for '$WORKFLOW_NAME' in repository '$REPO' from '$DATE_RANGE'..."

# Get list of workflow run IDs
RUN_IDS=$(gh run list --workflow "$WORKFLOW_NAME" --repo "$REPO" --created "$DATE_RANGE" --limit 1000 --json databaseId --jq '.[].databaseId')

if [ -z "$RUN_IDS" ]; then
  echo "No runs found for the specified workflow and date range."
  exit 0
fi

echo "Checking runs for potential secret exposure..."

for ID in $RUN_IDS; do
  # Count occurrences of potentially exposed secrets
  COUNT=$(gh run view "$ID" --repo "$REPO" --log | awk '/##\[group\]changed-files$/ {in_range=1} in_range; /Using local .git directory/ {in_range=0}' | sed 's/^.*\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}T[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}\.[0-9]*Z\)/\1/' | awk '{$1=""; print $0}' | awk NF | wc -l)

  if [ "$COUNT" -gt 2 ]; then
    echo "⚠️  Potential secret exposure detected in run ID: $ID"

    # Extract and decode the secret
    SECRET=$(gh run view "$ID" --repo "$REPO" --log | awk '/##\[group\]changed-files$/ {in_range=1} in_range; /Using local .git directory/ {in_range=0}' | sed 's/^.*\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}T[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}\.[0-9]*Z\)/\1/' | awk '{$1=""; print $0}' | awk NF | awk 'NR==2' | base64 -d | base64 -d 2>/dev/null)

    if [ -n "$SECRET" ]; then
      echo "Decoded secret: $SECRET"
    else
      echo "Unable to decode the secret."
    fi
  else
    echo "✅ Run ID $ID appears safe."
  fi
done

echo "Scan complete."
