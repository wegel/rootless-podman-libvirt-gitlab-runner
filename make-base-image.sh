#!/bin/sh
set -eu

image_name=${IMAGE_NAME:-debian-12-worker-base.qcow2}
root_password=${ROOT_PASSWORD:-$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c16)}
image_size=${IMAGE_SIZE:-6G} # we just need enough to install the packages; we resize when we create the VM

if [ -n "${VERBOSE:-} "]; then
	echo "root_password: ${root_password}"
fi

podman build . -t base-worker-image-builder:latest

podman run -i --rm -e IMAGE_NAME=${image_name} -e IMAGE_SIZE=${image_size} -e ROOT_PASSWORD=${root_password} \
	-v ${IMAGES_DIR}:/images \
	qcow2-image-customizer bash -s <<'EOF'
set -euo pipefail

apt update
DEBIAN_FRONTEND=noninteractive apt install -y linux-generic-hwe-22.04

export LIBGUESTFS_BACKEND=direct
virt-builder debian-12 \
    --size ${IMAGE_SIZE} \
    --output /images/${IMAGE_NAME} \
    --format qcow2 \
    --hostname gitlab-worker \
    --network \
    --install build-essential,make,git,git-lfs,openssh-server,podman,curl,wget,cloud-init \
    --run-command "curl -fsSL https://get.docker.com | sh" \
    --run-command "git lfs install --skip-repo" \
    --run-command "sed -E 's/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"net.ifnames=0 biosdevname=0\"/' -i /etc/default/grub" \
    --run-command "grub-mkconfig -o /boot/grub/grub.cfg" \
    --run-command "echo 'auto eth0' >> /etc/network/interfaces" \
    --run-command "echo 'allow-hotplug eth0' >> /etc/network/interfaces" \
    --run-command "echo 'iface eth0 inet dhcp' >> /etc/network/interfaces" \
    --run-command "sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config" \
    --run-command "sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config" \
    --root-password password:${ROOT_PASSWORD}
EOF
