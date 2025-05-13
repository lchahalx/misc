#!/bin/bash

set -euo pipefail

API_SERVER_IP=$(ip -o -4 addr list ens18 | awk '{print $4}' | cut -d/ -f1)
POD_CIDR="10.244.0.0/16"

echo "Updating system and installing dependencies..."
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl gpg

echo "Adding Kubernetes GPG key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "Adding Kubernetes apt repository..."
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "Installing kubelet, kubeadm, kubectl..."
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "Installing containerd..."
sudo apt-get install -y containerd

echo "Configuring containerd..."
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd

echo "Loading kernel modules..."
sudo modprobe br_netfilter
sudo modprobe overlay
sudo tee /etc/modules-load.d/k8s.conf <<EOF
br_netfilter
overlay
EOF

echo "Applying sysctl settings..."
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

echo "Initializing Kubernetes control plane..."
sudo kubeadm init --pod-network-cidr=$POD_CIDR --apiserver-advertise-address=$API_SERVER_IP

echo "Setting up kubeconfig for the current user..."
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "Applying Flannel CNI..."
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

echo "Reapplying kernel modules and sysctl configs..."
sudo systemctl restart systemd-modules-load.service
sudo systemctl daemon-reexec
sudo systemctl restart kubelet

echo "Restarting Flannel pod..."
kubectl delete pod -n kube-flannel -l app=flannel --ignore-not-found=true

# Status check: Kubernetes nodes and pods
echo "Checking Kubernetes cluster status..."
kubectl get nodes
kubectl get pods -A

