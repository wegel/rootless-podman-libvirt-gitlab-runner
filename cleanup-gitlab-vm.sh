#!/usr/bin/env bash
set -euo pipefail

currentDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source ${currentDir}/gitlab-vm-base.sh # Get variables from base script.

# Destroy VM.
virsh shutdown "$VM_ID"

# Undefine VM.
virsh undefine "$VM_ID"

rm -rf /tmp/${VM_ID}

# Delete VM disk.
if [ -f "$VM_IMAGE" ]; then
	rm "$VM_IMAGE"
fi
