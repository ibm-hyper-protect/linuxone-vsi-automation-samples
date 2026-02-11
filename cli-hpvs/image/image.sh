#!/usr/bin/env bash
set -euo pipefail

# Path to the CLI (adjust if needed)
CLI=./contract-cli

# Input file - IBM Cloud image list JSON
IMAGE_LIST_JSON="ibm_cloud_images.json"

# Output files
IMAGE_DETAILS_JSON="hpcr_image_details.json"
IMAGE_DETAILS_YAML="hpcr_image_details.yaml"
IMAGE_DETAILS_TEXT="hpcr_image_details.txt"

echo "=== Extract HPCR Image Details from IBM Cloud Image List ==="
echo ""
echo "This script extracts Hyper Protect Container Runtime (HPCR) image details"
echo "from an IBM Cloud image list JSON file. This is useful for identifying the"
echo "correct image ID and details needed for deploying HPCR instances."
echo ""

# Check if image list file exists
if [ ! -f "$IMAGE_LIST_JSON" ]; then
    echo "ERROR: Image list file not found: $IMAGE_LIST_JSON"
    exit 1
fi

echo "Using image list file: $IMAGE_LIST_JSON"
echo ""

# Example 1: Extract specific HPCR version in JSON format
echo "=== Example 1: Extract specific HPCR version (JSON format) ==="
"$CLI" image \
  --in "$IMAGE_LIST_JSON" \
  --version "ibm-hyper-protect-container-runtime-1-0-s390x-16" \
  --format json \
  --out "$IMAGE_DETAILS_JSON"

echo "Image details saved to: $IMAGE_DETAILS_JSON"
echo ""


# Example 2: Extract HPCR version in YAML format
echo "=== Example 2: Extract HPCR version (YAML format) ==="
"$CLI" image \
  --in "$IMAGE_LIST_JSON" \
  --version "ibm-hyper-protect-container-runtime-1-0-s390x-16" \
  --format yaml \
  --out "$IMAGE_DETAILS_YAML"

echo "Image details saved to: $IMAGE_DETAILS_YAML"
echo ""


# Example 3: Extract HPCR version in text format
echo "=== Example 3: Extract HPCR version (text format) ==="
"$CLI" image \
  --in "$IMAGE_LIST_JSON" \
  --version "ibm-hyper-protect-container-runtime-1-0-s390x-16" \
  --format text \
  --out "$IMAGE_DETAILS_TEXT"

echo "Image details saved to: $IMAGE_DETAILS_TEXT"
echo ""


# Example 4: Extract and output to stdout (JSON)
echo "=== Example 4: Extract and output to stdout ==="
"$CLI" image \
  --in "$IMAGE_LIST_JSON" \
  --version "ibm-hyper-protect-container-runtime-1-0-s390x-16" \
  --format json

echo ""


# Example 5: Extract different HPCR version
echo "=== Example 5: Extract different HPCR version ==="
echo "To extract a different version, specify the version name:"
echo "  $CLI image --in $IMAGE_LIST_JSON --version ibm-hyper-protect-container-runtime-1-0-s390x-17 --format json"
echo ""


# Example 6: Extract without version (gets latest)
echo "=== Example 6: Extract latest HPCR image ==="
echo "To get the latest HPCR image, omit the --version flag:"
echo "  $CLI image --in $IMAGE_LIST_JSON --format json --out latest_hpcr.json"
echo ""

echo "Script completed successfully!"
echo ""
echo "Next steps:"
echo "1. Review the extracted image details"
echo "2. Use the image ID for deploying HPCR instances"
echo "3. Verify the image version matches your requirements"
