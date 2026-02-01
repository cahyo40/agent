#!/bin/bash

# fetch-stitch.sh
# Reliably downloads Stitch assets from Google Cloud Storage
# Handles redirects and authentication that can fail with AI fetch tools

set -e

URL="$1"
OUTPUT="$2"

if [ -z "$URL" ] || [ -z "$OUTPUT" ]; then
  echo "Usage: bash fetch-stitch.sh <url> <output-path>"
  echo "Example: bash fetch-stitch.sh 'https://storage.googleapis.com/...' 'temp/source.html'"
  exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$(dirname "$OUTPUT")"

# Download with curl, following redirects
curl -L -o "$OUTPUT" "$URL"

# Verify download succeeded
if [ -f "$OUTPUT" ]; then
  echo "✓ Downloaded to: $OUTPUT"
  echo "  Size: $(wc -c < "$OUTPUT") bytes"
else
  echo "✗ Download failed"
  exit 1
fi
