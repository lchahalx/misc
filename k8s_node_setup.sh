#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

echo "Starting Kubernetes node setup..."

# Check OS
if ! grep -Eqi "ubuntu|debian" /etc/os-release; then
    echo "ERROR: This script is only for Ubuntu/Debian systems."
    exit 1
fi

# Update the system and install basic dependencies
apt-get update -y && apt-get upgrade -y
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common

# Disable swap
swapoff -a
sed -i.bak '/ swap / s/^/#/' /etc/fstab

# Load required kernel modules
modprobe overlay
modprobe br_netfilter

tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

# Apply sysctl settings
tee /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

# Install containerd
apt-get install -y containerd

mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml >/dev/null

sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd

# Add Kubernetes repository (secure method)
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | \
    gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" | \
    tee /etc/apt/sources.list.d/kubernetes.list

apt-get update

# Install kubelet, kubeadm, kubectl
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

systemctl enable kubelet

# Final verification
echo "Verifying installation..."
echo -n " - containerd: "; command -v containerd >/dev/null && echo "OK" || echo "NOT FOUND"
echo -n " - kubeadm:    "; command -v kubeadm >/dev/null && echo "OK" || echo "NOT FOUND"
echo -n " - kubelet:    "; command -v kubelet >/dev/null && echo "OK" || echo "NOT FOUND"
echo -n " - kubectl:    "; command -v kubectl >/dev/null && echo "OK" || echo "NOT FOUND"

echo "Kubernetes node setup complete."

