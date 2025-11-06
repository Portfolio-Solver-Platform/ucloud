terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.14.1"
    }
  }
}

variable "gc_user" {}

provider "google" {
  credentials = file("credentials.json")
  project     = "ctf-sdu"
  region      = "europe-north1"
  zone        = "europe-north1-a"
}

resource "google_compute_network" "ctf_network" {
  name = "terraform-network"
}

resource "google_compute_firewall" "ssh_rule" {
  name    = "ssh-enabled"
  network = google_compute_network.ctf_network.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "headscale_enabled" {
  name    = "headscale-enabled"
  network = google_compute_network.ctf_network.name
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_address" "ctf_static_addr" {
  name = "ctf-ipv4-static-address"
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_instance" "headscale_core_ctf" {
  name         = "headscale-core-ctf"
  machine_type = "e2-medium"
  boot_disk {
    initialize_params {
      size  = 20
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
    }
  }
  network_interface {
    network = google_compute_network.ctf_network.name
    access_config {
      nat_ip = google_compute_address.ctf_static_addr.address
    }
    
  }
  metadata = { ssh-keys = "${var.gc_user}:${file("../ucloud_key.pub")}" }
  tags     = []
}

resource "local_file" "hosts" {
  content = templatefile("hosts.tmpl",
    {
      headscale_core_ip = google_compute_instance.headscale_core_ctf.network_interface.0.access_config.0.nat_ip
      user = var.gc_user
    }
  )
  filename = "../ansible-gcp/hosts.ini"
}


resource "local_file" "headscale_config" {
  content = templatefile("headscale.yml.tmpl",
    {
      headscale_core_ip = google_compute_instance.headscale_core_ctf.network_interface.0.access_config.0.nat_ip
    }
  )
  filename = "../ansible-gcp/headscale.yml"
}
