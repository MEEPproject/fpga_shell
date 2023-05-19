
BITSTREAM_PATH=$1
REPORT_FILE=$2

# Generate the sha of a bitstream file:
echo -n bitstream | sha256sum


#!/bin/bash

# Check if path is provided as parameter
if [ $# -ne 1 ]; then
  echo "Usage: $0 <path>"
  exit 1
fi

# Check if path exists
if [ ! -d "$BITSTREAM_PATH" ]; then
  echo "Directory does not exist: $BITSTREAM_PATH"
  exit 1
fi

# Find all .bit files in the directory and calculate their SHA-256 hash
find "$BITSTREAM_PATH" -name '*.bit' -type f -print0 | while read -d $'\0' bitfile; do
  sha=sha256sum "$bitfile"
  mydate=$(date +%m.%d.%Y)
  python connector.py($sha,$bitfile,$mydate,$REPORT_FILE)
done
