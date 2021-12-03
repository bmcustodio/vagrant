#!/bin/bash

set -euo pipefail

ARCH="$(dpkg --print-architecture)"

function install_chezmoi() {
  curl -fsSLo chezmoi.deb https://github.com/twpayne/chezmoi/releases/download/v2.9.1/chezmoi_2.9.1_linux_amd64.deb
  sudo apt install --yes ./chezmoi.deb
}

function install_cilium_cli() {
  curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz{,.sha256sum}
  sha256sum --check cilium-linux-amd64.tar.gz.sha256sum
  sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin
}

function install_docker() {
  DOCKER_ARCHIVE_KEYRING="/usr/share/keyrings/docker-archive-keyring.gpg"
  sudo rm -f "${DOCKER_ARCHIVE_KEYRING}"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --dearmor -o "${DOCKER_ARCHIVE_KEYRING}"
  cat <<EOF | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
deb [arch=${ARCH} signed-by=${DOCKER_ARCHIVE_KEYRING}] https://download.docker.com/linux/ubuntu focal stable
EOF
  sudo apt update
  sudo apt install --yes containerd.io docker-ce docker-ce-cli
}

function install_go() {
  sudo add-apt-repository ppa:longsleep/golang-backports
  sudo apt update
  sudo apt install --yes golang-go
}

function install_helm() {
  curl -fsSL -o helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  chmod 700 helm.sh
  ./helm.sh
}

function install_k9s() {
  curl -fsSLo k9s.tar.gz https://github.com/derailed/k9s/releases/download/v0.25.6/k9s_Linux_x86_64.tar.gz
  sudo tar xzvfC k9s.tar.gz /usr/local/bin
}

function install_kind() {
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
  chmod +x ./kind
  sudo mv ./kind /usr/local/bin/kind
}

function install_kube_ps1() {
  TARGET="${HOME}/.kube-ps1"
  rm -rf "${TARGET}"
  git clone https://github.com/jonmosco/kube-ps1 "${TARGET}"
}

function install_kubectl() {
  KUBERNETES_ARCHIVE_KEYRING="/usr/share/keyrings/kubernetes-archive-keyring.gpg"
  sudo rm -f "${KUBERNETES_ARCHIVE_KEYRING}"
  sudo curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --batch --dearmor -o "${KUBERNETES_ARCHIVE_KEYRING}"
  cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
deb [arch=${ARCH} signed-by=${KUBERNETES_ARCHIVE_KEYRING}] https://apt.kubernetes.io kubernetes-xenial main
EOF
  sudo apt update
  sudo apt install --yes kubectl
}

function install_minikube() {
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  sudo install minikube-linux-amd64 /usr/local/bin/minikube
}

function install_neovim() {
  sudo add-apt-repository ppa:neovim-ppa/stable
  sudo apt update
  sudo apt install --yes neovim
}

function install_oh_my_zsh() {
  if [[ ! -d "${HOME}/.oh-my-zsh" ]];
  then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)";
  fi
}

function install_terraform() {
  curl -fsSLo terraform.zip https://releases.hashicorp.com/terraform/1.0.11/terraform_1.0.11_linux_amd64.zip
  unzip terraform.zip
  sudo mv terraform /usr/local/bin
}

function install_tpm() {
  TARGET="${HOME}/.tmux/plugins/tpm"
  rm -rf "${TARGET}"
  git clone https://github.com/tmux-plugins/tpm "${TARGET}"
}

DIR="$(mktemp -d)"
pushd "${DIR}" > /dev/null

# Silence MOTD.
touch "${HOME}/.hushlogin"

# Set locales.
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
sudo dpkg-reconfigure -f noninteractive locales

# Configure PATH for this session.
export PATH="${HOME}/bin:${PATH}"

# Install updates and basic stuff.
sudo apt update
sudo apt full-upgrade --yes
sudo apt install --yes autojump build-essential git vim unzip zsh

# Install utils.
install_chezmoi
install_cilium_cli
install_docker
install_go
install_helm
install_k9s
install_kind
install_kube_ps1
install_kubectl
install_minikube
install_neovim
install_oh_my_zsh
install_terraform
install_tpm

chezmoi init --apply --branch main --force bmcustodio
sudo usermod -aG docker "$(whoami)"
sudo chsh -s /bin/zsh "$(whoami)"

popd > /dev/null
rm -rf "${DIR}"
