#!/bin/bash

echo "[INFO] Stopping kubelet and container runtime..."
sudo systemctl stop kubelet
sudo systemctl stop containerd || sudo systemctl stop docker

echo "[INFO] Removing CNI config and data directories..."
sudo rm -rf /etc/cni/net.d/*
sudo rm -rf /var/lib/cni/*
sudo rm -rf /var/lib/calico/*

echo "[INFO] Deleting CNI virtual interfaces if they exist..."
sudo ip link delete cni0 2>/dev/null
sudo ip link delete flannel.1 2>/dev/null
sudo ip link delete tunl0 2>/dev/null

echo "[INFO] Starting container runtime and kubelet..."
sudo systemctl start containerd || sudo systemctl start docker
sudo systemctl start kubelet

echo "[INFO] Node cleanup complete. Reapply Calico manifest from control plane."

