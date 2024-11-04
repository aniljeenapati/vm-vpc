resource "google_compute_network" "custom_vpc" {
  name                    = "custom-vpc"
  auto_create_subnetworks = false  # Disable automatic subnet creation
}

resource "google_compute_subnetwork" "custom_subnet" {
  name          = "custom-subnet"
  ip_cidr_range = "10.0.0.0/24"  # Change CIDR as needed
  region       = "us-east1"  # Must match the provider region
  network      = google_compute_network.custom_vpc.name
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = google_compute_network.custom_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]  # Allow traffic from anywhere
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.custom_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]  # Allow SSH access from anywhere
}

resource "google_compute_instance" "centos_instance" {
  name         = "centos-instance"
  machine_type = "e2-micro"  # Change as needed
  zone         = "us-east1-a"  # Change to your desired zone

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"  # Use CentOS 7 image
    }
  }

  network_interface {
    network    = google_compute_network.custom_vpc.name
    subnetwork = google_compute_subnetwork.custom_subnet.name
    access_config {}  # Allocate a public IP address
  }

  metadata = {
    startup-script = <<-EOT
      #!/bin/bash
      yum update -y
      yum install -y httpd
      systemctl enable httpd
      systemctl start httpd
    EOT
  }
}
