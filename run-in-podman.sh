#!/bin/sh
set -eu

container_name=${CONTAINER_NAME:-gitlab-runner-libvirt}
container_image_name=${CONTAINER_IMAGE_NAME:-localhost/gitlab-runner-libvirt:latest}
libvirt_dir=${LIBVIRT_DIR:-~/.local/containers/gitlab-runner/libvirt}
gitlab_runner_config_file=${GITLAB_RUNNER_CONFIG_FILE:-~/.local/containers/gitlab-runner/config.toml}

echo "Starting container ${container_name} from image ${container_image_name}..."
echo "Using libvirt directory: ${libvirt_dir}"
echo "Using GitLab Runner config file: ${gitlab_runner_config_file}"

podman rm --force ${container_name} || true
podman run -di --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
	-v ${gitlab_runner_config_file}:/etc/gitlab-runner/config.toml \
	-v ${libvirt_dir}:/var/lib/libvirt \
	--name ${container_name} ${container_image_name}
