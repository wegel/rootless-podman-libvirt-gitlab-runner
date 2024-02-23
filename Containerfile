FROM ubuntu:22.04

RUN DEBIAN_FRONTEND=noninteractive apt update && apt install -y systemd curl wget git git-lfs cloud-image-utils qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst libguestfs-tools vim && apt clean
RUN curl -L --output /usr/local/bin/gitlab-runner "https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/binaries/gitlab-runner-linux-amd64" \
  && chmod +x /usr/local/bin/gitlab-runner
RUN useradd -m -s /bin/bash gitlab-runner
RUN gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner

RUN systemctl enable gitlab-runner.service libvirtd.service

COPY gitlab-vm-base.sh /home/gitlab-runner/
COPY prepare-gitlab-vm.sh /home/gitlab-runner/
COPY cleanup-gitlab-vm.sh /home/gitlab-runner/
COPY run-gitlab-vm.sh /home/gitlab-runner/
COPY qemu.conf /etc/libvirt/

CMD [ "/usr/sbin/init" ]

