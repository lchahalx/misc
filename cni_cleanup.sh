#!/bin/bash

echo "[INFO] Stopping kubelet to avoid race conditions..."
systemctl stop kubelet

echo "[INFO] Removing Flannel/old CNI configs..."
rm -v /etc/cni/net.d/*flannel*.conf
rm -v /etc/cni/net.d/10-flannel.conflist
rm -v /etc/cni/net.d/*loopback.conf

echo "[INFO] Cleaning up Flannel binaries (optional)..."
rm -v /opt/cni/bin/flannel
rm -v /opt/cni/bin/loopback

echo "[INFO] Flushing residual CNI interfaces and bridges..."
ip link delete cni0 2>/dev/null
ip link delete flannel.1 2>/dev/null
ip link delete docker0 2>/dev/null
ip link delete tunl0 2>/dev/null
ip link delete vxlan.calico 2>/dev/null

echo "[INFO] Removing stale iptables rules (NAT, FORWARD)..."
iptables -t nat -F
iptables -F
iptables -X

echo "[INFO] Enabling IP forwarding..."
sysctl -w net.ipv4.ip_forward=1
modprobe br_netfilter
sysctl -w net.bridge.bridge-nf-call-iptables=1
sysctl -w net.bridge.bridge-nf-call-ip6tables=1

echo "[INFO] Starting kubelet again..."
systemctl start kubelet

echo "[SUCCESS] Cleanup completed."

