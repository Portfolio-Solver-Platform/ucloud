# UCloud

This repository contains the Infrastructure as Code (IaC) for PSP.
It is based on [ucloud-k8s by Matteo Trentin](https://github.com/mattrent/ucloud-k8s/tree/main).

> [!WARNING]
> This repository is currently under development, and not ready for use.

## Usage

You need one VM for the gateway and one or more for the Kubernetes cluster.

### Kubernetes

Requirements:

- a key to access UCloud machines through SSH. The key location is set in `ansible/ansible.cfg`
- a [Tailscale auth key](https://tailscale.com/kb/1085/auth-keys). The Ansible playbook expects it to be in the `tailscale_key` file at the root level of this repo. Can be changed in the "`connect to tailscale`" task, in the `tailscale` role.
- a `hosts.ini` file in the `kubernetes/ansible/` directory. See `hosts.ini.example` for the expected roles.

To run:

```
ansible-playbook cluster.yml
```

from the `kubernetes/ansible/` directory.
