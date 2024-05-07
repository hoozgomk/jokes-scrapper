variable "credentials_file" {
  description = "Path to the Google Cloud service account credentials JSON file"
}

variable "public_key_file" {
  description = "Path to the public SSH key file"
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = "jokes-scrapper"
  region      = "us-central1"
}

# Define custom VPC
resource "google_compute_network" "jokes_scrapper_vpc" {
  name                    = "jokes-scrapper-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "custom_subnet" {
  name          = "jokes-scrapper-subnet"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.jokes_scrapper_vpc.id
  region        = "us-central1"
}

# Reserve static IP for VM
resource "google_compute_address" "static_ip" {
  name    = "jokes-scrapper-static-ip"
  project = "jokes-scrapper"
}

# Define name, machine type and zone for VM
resource "google_compute_instance" "jokes_scrapper_vm" {
  name         = "jokes-scrapper-vm"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

# Set Container-Optimized Image as it has docker preinstalled
  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }

  allow_stopping_for_update = true

  network_interface {
    network    = google_compute_network.jokes_scrapper_vpc.id
    subnetwork = google_compute_subnetwork.custom_subnet.id
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }

# Read SSH public key from file and add it to the VM
metadata = {
  "ssh-keys" = "github:${file(var.public_key_file)}"
}
}

# Allow to access application port
resource "google_compute_firewall" "allow_app" {
  name    = "jokes-scrapper-fw"
  network = google_compute_network.jokes_scrapper_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Allow SSH to VM
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.jokes_scrapper_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}
