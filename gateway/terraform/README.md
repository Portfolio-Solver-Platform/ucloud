# How to use this Terraform script

## With OpenTofu

To create:

```bash
tofu apply
```

To destroy:

```bash
tofu apply -destroy -target="google_compute_network.ctf_network" -target="google_compute_firewall.ssh_rule" -target="google_compute_firewall.headscale_enabled" -target="google_compute_instance.headscale_core_ctf" -target="local_file.hosts" -target="local_file.headscale_config"
```

## With Terraform

To create:

```bash
terraform apply
```

To destroy:

```bash
terraform destroy -target="google_compute_network.ctf_network" -target="google_compute_firewall.ssh_rule" -target="google_compute_firewall.headscale_enabled" -target="google_compute_instance.headscale_core_ctf" -target="local_file.hosts" -target="local_file.headscale_config"
```
