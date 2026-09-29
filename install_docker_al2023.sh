# Setup docker
dnf install -y docker
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
