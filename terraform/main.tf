provider "google" {
  credentials = file("/Users/michalkabocik/Documents/jokes-scrapper/jokes-scrapper.json")
  project     = "jokes-scrapper"
  region      = "us-central1"
}

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

resource "google_compute_address" "static_ip" {
  name    = "jokes-scrapper-static-ip"
  project = "jokes-scrapper"
}

resource "google_compute_instance" "jokes_scrapper_vm" {
  name         = "jokes-scrapper-vm"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

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

  service_account {
    email  = "artifact-registry-reader@jokes-scrapper.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  metadata = {
    "ssh-keys" = <<EOT
      github:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9qXXNhBJlVrypZcsOoOTiQrIGzysPMjixGwFEfIZmsWr4wRyODs4CPyp8Pswis8Ofjxt8f6Qnsww5DX1uRjfWdJ265l1gt8GwzFhdAOB/CDKy7gt6+u81lIksNcJ4X6kHxminMuDsQVyP87NERlqjPyjQ9OD3+rnbBEGea68hzDIkWsDjET0wG48gVfedkeoS7jIVHkd8FQ4gsyilxf4gRSghKP7okEkupv4thGwf5tLsDlCoJ1SkRYl3terCyB1m6qdd5lmX0vwcNu/emLdy8tZhpswIK3Miw+b41o4evGNQcxAKR7prcXf4Fu8nIrN4PZElywQBRiIsjEm7aPmNdoTD4/NcdUcH75rlrIySA1FtRWGVgFsC3vErhzAOqqPjmr2XVNTfCjPu9RTEXt0/D5AbJc4zvvjD0JgTSqxSbrfzIR6F8A2087uXortnOgApdAREcoYJE59iRuEgnNzEWD6W/c/wvYB9c7GOB2XHHcmZ4/W+GFz0tirzt3rnkmudLcaa5d/TKJO7SI3Pw4nK4YcEv+d2x59nWCq2M5xEkpVdvtPA6u7mgCvWSGQkXOUbJS5e9ftIQXPAeV9whmhfUhQR1luwed9DltjaLbPcmZBd4Mg+uUEyE82o1Lwk7XycTN+WBe6/HYAeMPNr+r65cjqrzYj7m7trqPx5HuwSAQ== jokes-scrapper
     EOT
  }
}

resource "google_compute_firewall" "allow_app" {
  name    = "jokes-scrapper-fw"
  network = google_compute_network.jokes_scrapper_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.jokes_scrapper_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}
