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
  disable_on_destroy = false
}

# enable service api for vpc access
resource "google_project_service" "vpc_access" {
  service = "vpcaccess.googleapis.com"
  disable_on_destroy = false
}

resource "google_service_account" "default" {
  account_id   = "whisper-service-account-id"
  display_name = "whisper Service Account"
}

# attach iam role to service_account for compute service
resource "google_project_iam_member" "compute_service_account" {
  role   = "roles/compute.instanceAdmin.v1"
  member = "serviceAccount:${google_service_account.default.email}"
  project = var.project_id
}

resource "google_compute_instance" "default" {
  count        = var.number_vms
  name         = "${var.instance_name}-${count.index}"
  machine_type = var.instance_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.os_image
    }
  }

  dynamic "guest_accelerator" {
    for_each = var.number_gpus > 0 ? [1] : []
    content {
      count  = var.number_gpus
      type   = var.gpu_type
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  scheduling {
    preemptible = true
    on_host_maintenance = "TERMINATE"
    provisioning_model          = "SPOT"
    instance_termination_action = "DELETE"
    automatic_restart = false
  }

  metadata = {
    ssh-keys = "debian:${file("../id_rsa.pub")}"
  }

  service_account {
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_firewall" "firewall" {
  name    = "allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  depends_on = [google_project_service.vpc_access]
}

resource "local_file" "hosts_cfg" {
  content = templatefile("../templates/hosts.tpl_debian",
    {
      vms = google_compute_instance.default[*].network_interface.0.access_config.0.nat_ip
    }
  )
  filename = "../ansible/hosts.cfg"
}
