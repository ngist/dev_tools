#!/bin/bash
dnf install -y git pip docker jq

# Setup docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

echo "Manually installing docker compose plugin and buildx"
latest_plugin_vers() {
    plugin=$1
    vers=$(curl -s https://api.github.com/repos/docker/$plugin/releases/latest | jq -r '.tag_name')
    echo $vers
}

PLUGIN_DIR=/usr/libexec/docker/cli-plugins
mkdir -p $PLUGIN_DIR

platform=$(uname -s)
platform=${platform,,}
arch=$(uname -m)
arch_munged=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')

COMPOSE_VER=$(latest_plugin_vers compose)
COMPOSE_URL="https://github.com/docker/compose/releases/download/$COMPOSE_VER/docker-compose-$platform-$arch"
curl -sL $COMPOSE_URL -o $PLUGIN_DIR/docker-compose
# Set ownership to root and make executable
test -f $PLUGIN_DIR/docker-compose \
  && chmod +x $PLUGIN_DIR/docker-compose

BUILDX_VER=$(latest_plugin_vers buildx)
BUILDX_URL="https://github.com/docker/buildx/releases/download/$BUILDX_VER/buildx-$BUILDX_VER.$platform-$arch_munged"
curl -sL $BUILDX_URL -o $PLUGIN_DIR/docker-buildx
# Set ownership to root and make executable
test -f $PLUGIN_DIR/docker-buildx \
  && chmod +x $PLUGIN_DIR/docker-buildx

cat <<'EOF2' > /etc/ssh/ssh_known_hosts
github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=
codeberg.org ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBL2pDxWr18SoiDJCGZ5LmxPygTlPu+cCKSkpqkvCyQzl5xmIMeKNdfdBpfbCGDPoZQghePzFZkKJNR/v9Win3Sc=
codeberg.org ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8hZi7K1/2E2uBX8gwPRJAHvRAob+3Sn+y2hxiEhN0buv1igjYFTgFO2qQD8vLfU/HT/P/rqvEeTvaDfY1y/vcvQ8+YuUYyTwE2UaVU5aJv89y6PEZBYycaJCPdGIfZlLMmjilh/Sk8IWSEK6dQr+g686lu5cSWrFW60ixWpHpEVB26eRWin3lKYWSQGMwwKv4LwmW3ouqqs4Z4vsqRFqXJ/eCi3yhpT+nOjljXvZKiYTpYajqUC48IHAxTWugrKe1vXWOPxVXXMQEPsaIRc2hpK+v1LmfB7GnEGvF1UAKnEZbUuiD9PBEeD5a1MZQIzcoPWCrTxipEpuXQ5Tni4mN
codeberg.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVIC02vnjFyL+I4RHfvIGNtOgJMe769VTF1VR4EB3ZB
EOF2


git clone https://github.com/ngist/dev_tools.git /tmp/dev_tools
# Install auto_shutdown service, it shuts the instance down when idle for ~1hr.
/tmp/dev_tools/auto_shutdown/install.sh
# Install ddns service so that the instance can be accessed by a consistent domain name without needing to check at every start.
/tmp/dev_tools/ddns/install.sh
rm -rf /tmp/dev_tools

# Get Github credentials
aws ssm get-parameter --name GitHubKeyForDevBox --with-decryption --query "Parameter.Value" --output text > /home/ec2-user/.ssh/id_ed25519
chmod 600 /home/ec2-user/.ssh/id_ed25519
chown ec2-user:ec2-user /home/ec2-user/.ssh/id_ed25519

# Setup git
# sudo -u ec2-user git config --global user.name "NAME"
# sudo -u ec2-user git config --global user.email "EMAIL"
sudo -u ec2-user git config --global alias.co checkout
sudo -u ec2-user git config --global alias.br branch
sudo -u ec2-user git config --global alias.st status
