terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.53.1"
    }
  }
}
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# enable service api for compute
resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

# enable service api for vpc access
resource "google_project_service" "vpc_access" {
  service = "vpcaccess.googleapis.com"
}

resource "google_compute_instance_template" "default" {
  name_prefix  = var.instance_name
  machine_type = var.instance_type
  #machine_type = "a2-highgpu-1g"

  guest_accelerator {
    type = var.gpu_type
    #type = "nvidia-tesla-a100"
    count = var.number_gpus
    #count = 1
  }

  disk {
    auto_delete   = true
    boot          = true
    source_image  = var.os_image
    #source_image = "projects/debian-cloud/global/images/debian-11-bullseye-v20220110"
    type          = "pd-ssd"
    size          = 50
  }

  network_interface {
    network = "default"
    access_config {
      // Allocate a public IP address for the instance
    }
  }

  metadata = {
    ssh-keys = "debian:${file(var.ssh_key)}"
  }

  scheduling {
    preemptible = true
  }
  depends_on = [google_project_service.compute]
}

resource "google_compute_instance_group_manager" "default" {
  name = "whisper-igm"
  base_instance_name = var.instance_name
  instance_template = google_compute_instance_template.default.self_link

  target_size = var.number_vms

  depends_on = [google_project_service.compute]
}

resource "google_compute_firewall" "firewall" {
  name    = "allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}
