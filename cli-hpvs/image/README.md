# Image Details Extraction Script

This script extracts Hyper Protect Container Runtime (HPCR) image details from an IBM Cloud image list JSON file using `contract-cli`. This is essential for identifying the correct image ID and specifications needed for deploying HPCR instances on IBM Cloud.

## Prerequisites

Prepare your environment according to [these steps](../README.md).
Ensure that the HPVS CLI tool (contract-cli) is downloaded, renamed, and available on your system as described earlier.

## Usage

### 1. Configure the CLI path
Open the `image.sh` script and update the CLI variable to point to the location where you downloaded the `contract-cli` binary.

Example:
```text
CLI=./contract-cli
```

### 2. Obtain IBM Cloud Image List

First, get the list of public images from IBM Cloud using the IBM Cloud CLI:
Update the input file path in the script:
```bash
IMAGE_LIST_JSON="ibm_cloud_images.json"
```

### 3. Run the Script
Make the script executable and run it:

```bash
chmod +x image.sh
./image.sh
```

## What the Script Does

The script demonstrates six usage examples:

### Example 1: Extract Specific Version (JSON format)
- Extracts details for a specific HPCR version
- Saves output in JSON format

### Example 2: Extract in YAML Format
- Same extraction but in YAML format

### Example 3: Extract in Text Format
- Plain text output

### Example 4: Output to Stdout
- Prints image details directly to terminal

### Example 5: Extract Different Version
- Shows how to extract a different HPCR version

### Example 6: Extract Latest Image
- Gets the most recent HPCR image
- Useful when you always want the latest version

## Command Options

### image Command

#### Required Flags
- `--in`: Path to IBM Cloud image list JSON file

#### Optional Flags
- `--version`: Specific HPCR version name (e.g., `ibm-hyper-protect-container-runtime-1-0-s390x-16`)
- `--format`: Output format - `json` (default), `yaml`, or `text`
- `--out`: Path to save extracted image details (prints to stdout if not specified)

## Examples

### Extract specific HPCR version in JSON:
```bash
./contract-cli image \
  --in ibm_cloud_images.json \
  --version ibm-hyper-protect-container-runtime-1-0-s390x-16 \
  --format json \
  --out hpcr_image.json
```

### Extract in YAML format:
```bash
./contract-cli image \
  --in ibm_cloud_images.json \
  --version ibm-hyper-protect-container-runtime-1-0-s390x-16 \
  --format yaml \
  --out hpcr_image.yaml
```

### Extract and output to stdout:
```bash
./contract-cli image \
  --in ibm_cloud_images.json \
  --version ibm-hyper-protect-container-runtime-1-0-s390x-16 \
  --format json
```

### Extract latest HPCR image:
```bash
./contract-cli image \
  --in ibm_cloud_images.json \
  --format json \
  --out latest_hpcr.json
```

### Extract for specific region:
```bash
# Get images for specific region
ibmcloud target -r eu-de
ibmcloud is images --visibility public --output json > eu_images.json

# Extract HPCR image
./contract-cli image \
  --in eu_images.json \
  --version ibm-hyper-protect-container-runtime-1-0-s390x-16 \
  --format json \
  --out eu_hpcr_image.json
```

## Output Format Examples

### JSON Output
```json
{
  "id": "r006-1234abcd-5678-90ef-ghij-klmnopqrstuv",
  "name": "ibm-hyper-protect-container-runtime-1-0-s390x-16",
  "architecture": "s390x",
  "operating_system": {
    "name": "ubuntu-20-04-amd64"
  },
  "status": "available",
  "visibility": "public"
}
```

### YAML Output
```yaml
id: r006-1234abcd-5678-90ef-ghij-klmnopqrstuv
name: ibm-hyper-protect-container-runtime-1-0-s390x-16
architecture: s390x
operating_system:
  name: ubuntu-20-04-amd64
status: available
visibility: public
```

### Text Output
```text
ID: r006-1234abcd-5678-90ef-ghij-klmnopqrstuv
Name: ibm-hyper-protect-container-runtime-1-0-s390x-16
Architecture: s390x
Status: available
```

## Troubleshooting

### Error: "Image list file not found"
- Verify the file path is correct

### Error: "Image version not found"
- Check the version name spelling and format
- List available HPCR images: `jq '.[] | select(.name | contains("hyper-protect"))' ibm_cloud_images.json`
- Verify the version exists in your target region

### Error: "Invalid JSON format"
- Ensure the input file is valid JSON
- Re-download the image list from IBM Cloud
- Check file is not corrupted or truncated

### Empty or No Results
- Verify you're using the correct region
- Check that HPCR images are available in your target region
- Ensure the image list file contains public images

### Wrong Architecture
- HPCR only runs on s390x architecture (IBM Z/LinuxONE)
- Verify you're targeting a region with s390x support
- Check image name includes `s390x`