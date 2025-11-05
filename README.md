# UCloud

This repository contains the Infrastructure as Code (IaC) for PSP.
It is based on [ucloud-k8s by Matteo Trentin](https://github.com/mattrent/ucloud-k8s/tree/main).

> [!DANGER]
> This repository is currently under development, and not ready for use.

## Usage

Requirements:

- a key to access uCloud machines through SSH. The key location is set in `ansible/ansible.cfg`
- a `hosts.ini` file in the `ansible` directory. See `hosts.ini.example` for the expected roles.

To run:

```
ansible-playbook cluster.yml
```

from the `ansible/` directory.
