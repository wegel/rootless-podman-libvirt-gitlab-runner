#!/usr/bin/env bash
set -euo pipefail

currentDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source ${currentDir}/gitlab-vm-base.sh # Get variables from base script.

VM_IP=$(_get_vm_ip)

ssh -i /tmp/$VM_ID/id_ed25519 -o LogLevel=error -o ServerAliveInterval=60 -o ServerAliveCountMax=10 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@"$VM_IP" /bin/bash <"${1}"
if [ $? -ne 0 ]; then
	# Exit using the variable, to make the build as failure in GitLab
	# CI.
	exit "$BUILD_FAILURE_EXIT_CODE"
fi
