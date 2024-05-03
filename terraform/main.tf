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
  ip_cidr_range = "10.0.0.0/24"  # Update with your desired CIDR range
  network       = google_compute_network.jokes_scrapper_vpc.id
  region        = "us-central1"   # Update with your desired region
}

resource "google_compute_instance" "jokes_scrapper_vm" {
  name         = "jokes-scrapper-vm"
  machine_type = "e2-micro"
  zone         = "us-central1-a"  # Choose your desired zone

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"  # Using Container-Optimized OS image
    }
  }

  allow_stopping_for_update = true

  network_interface {
    network = google_compute_network.jokes_scrapper_vpc.id
    subnetwork = google_compute_subnetwork.custom_subnet.id
    access_config {}
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
