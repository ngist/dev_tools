#!/bin/bash
dnf install -y git pip docker

# Setup git
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.st status

# Setup docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

echo "Manually installing docker compose plugin and buildx"
mkdir -p /usr/local/lib/docker/cli-plugins

sudo curl -sL https://github.com/docker/compose/releases/download/latest/docker-compose-$(uname -s)-$(uname -m) \
  -o /usr/local/lib/docker/cli-plugins/docker-compose

# Set ownership to root and make executable
test -f /usr/local/lib/docker/cli-plugins/docker-compose \
  && sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

ARCH=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')
BUILDX_URL=$(curl -s https://api.github.com/repos/docker/buildx/releases/latest | grep "browser_download_url.*linux-$ARCH" | cut -d '"' -f 4)

curl -L $BUILDX_URL -o ~/.docker/cli-plugins/docker-buildx

cat <<'EOF2' > /etc/ssh/ssh_known_hosts
github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=
EOF2

# Get Github credentials
aws ssm get-parameter --name GitHubKeyForDevBox --with-decryption --query "Parameter.Value" --output text > /home/ec2-user/.ssh/id_ed25519
chmod 600 /home/ec2-user/.ssh/id_ed25519
chown ec2-user:ec2-user /home/ec2-user/.ssh/id_ed25519
