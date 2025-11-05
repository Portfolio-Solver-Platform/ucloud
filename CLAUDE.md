# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository contains Infrastructure as Code (IaC) for deploying a Kubernetes cluster with Headscale (self-hosted Tailscale coordination server) on uCloud infrastructure. The setup uses Ansible for configuration management.

**Note**: The Headscale coordination server and gateway are not yet implemented in this repository. Currently, nodes are configured with the `tailscale` role to connect to an external Headscale server.

## Architecture

The system deploys a Kubernetes cluster on uCloud infrastructure (`ansible/` directory).

### Networking Strategy

- All cluster nodes communicate via Tailscale VPN (tailscale0 interface)
- Kubernetes API server advertises on the Tailscale IP
- Flannel pod network is configured to use tailscale0 as its network interface
- Headscale server acts as the coordination server for the Tailscale network

### Kubernetes Stack

- **Container runtime**: Docker with cri-dockerd shim (Kubernetes dropped native Docker support)
- **Pod network**: Flannel CNI configured for Tailscale interface
- **Deployment tools**: Pulumi (installed on control plane), Helm

## Running Playbooks

Prerequisites:
- SSH key configured in `ansible/ansible.cfg` (default: `~/.ssh/id_ed25519`)
- Tailscale auth key in `tailscale_key` file at repository root
- `ansible/hosts.ini` file (see `ansible/hosts.ini.example`)

```bash
cd ansible
ansible-playbook cluster.yml
```

The `hosts.ini` must define:
- `[control_plane]` group: Single control plane node
- `[workers]` group: Worker nodes
- `[k8s-cluster:vars]` with `tailscale_login_server` pointing to an external Headscale server

## Role Organization

### Main Cluster Roles (`ansible/roles/`)

Applied in this order per `ansible/cluster.yml`:

**All nodes (k8s-cluster group):**
- `docker`: Installs Docker with systemd cgroup driver
- `cri-dockerd`: Installs cri-dockerd shim for Kubernetes-Docker compatibility

**Control plane only:**
- `kubernetes/control`: Initializes cluster with kubeadm, configures Flannel for Tailscale, generates join token
- `ctf-deps`: Installs Pulumi, NVM/Node.js 22, Helm
- `pulumi-deploy`: (Empty role, placeholder for future Pulumi deployments)

**Workers only:**
- `kubernetes/worker`: Joins worker nodes using join command from control plane

### Additional Roles

- `tailscale`: Downloads and installs Tailscale, connects to specified login server with auth key
- `commons/pre-install`: Common system package installation
- `commons/control-plane-deps`: Dependencies specific to control plane

## Key Implementation Details

### Kubernetes Initialization

The control plane role (`kubernetes/control/tasks/main.yml:9`) initializes with:
- Pod network CIDR: 10.244.0.0/16
- CRI socket: unix:///var/run/cri-dockerd.sock
- API server advertise address: Tailscale IP (dynamically fetched)

### Join Token Generation

Control plane generates join command and stores in `join_command` fact, which workers access via `hostvars['control'].join_command` (kubernetes/worker/tasks/main.yml:3).

### Flannel Configuration

Flannel manifest is modified post-download to add `--iface=tailscale0` argument to ensure pod networking uses VPN interface (kubernetes/control/tasks/main.yml:39).

## Configuration Files

- `ansible/ansible.cfg`: SSH key location, pipelining enabled, profile_tasks callback
- `ansible/hosts.ini`: Inventory (gitignored, see `.example` file)
- `tailscale_key`: Auth key for Tailscale (gitignored, must be created manually)

## Common Issues

- Ansible tasks may fail if Tailscale is not properly connected before Kubernetes init
- Worker join may fail if control plane `cluster_initialized.txt` doesn't exist
- Idempotency issues noted in `pulumi-deploy` role (see TODO comment)
- Some roles (like tailscale) have TODOs about splitting control/worker behavior
