# GCP VPC Network
resource "google_compute_network" "main" {
  name                    = "vpc-${var.app_name}"
  auto_create_subnetworks = false  # We will define custom subnets

  project = var.project_id  # GCP Project ID

  labels = {
    Name = "vpc-${var.app_name}"
  }
}

# GCP Subnets
resource "google_compute_subnetwork" "private_subnet" {
  count = length(var.availability_zones)

  name          = "private-subnet-${var.app_name}-${count.index}"
  ip_cidr_range = cidrsubnet(var.cidr_block, 4, count.index)
  region        = var.region
  network       = google_compute_network.main.id
  private_ip_google_access = true  # Enable private access to Google APIs

  labels = {
    Name = "private-subnet-${var.app_name}"
  }
}

resource "google_compute_subnetwork" "public_subnet" {
  count = length(var.availability_zones)

  name          = "public-subnet-${var.app_name}-${count.index}"
  ip_cidr_range = cidrsubnet(var.cidr_block, 2, count.index)
  region        = var.region
  network       = google_compute_network.main.id

  labels = {
    Name = "public-subnet-${var.app_name}"
  }
}

# GCP Firewall Rules (equivalent to AWS Security Groups)
resource "google_compute_firewall" "main" {
  name    = "${var.app_name}-firewall-${var.env_name}"
  network = google_compute_network.main.id

  allow {
    protocol = "tcp"
    ports    = ["${var.container_port}", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]  # Allow from anywhere

  direction = "INGRESS"
  priority  = 1000

  target_tags = ["${var.app_name}-instance"]

  labels = {
    Client = var.org_name
  }
}

resource "google_compute_firewall" "egress" {
  name    = "${var.app_name}-firewall-egress-${var.env_name}"
  network = google_compute_network.main.id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  destination_ranges = ["0.0.0.0/0"]  # Allow to anywhere

  direction = "EGRESS"
  priority  = 1000

  target_tags = ["${var.app_name}-instance"]

  labels = {
    Client = var.org_name
  }
}

# GCP Router (for NAT)
resource "google_compute_router" "router" {
  name    = "${var.app_name}-router-${var.env_name}"
  network = google_compute_network.main.name
  region  = var.region

  labels = {
    Name = "router-${var.app_name}"
  }
}

# GCP NAT Gateway
resource "google_compute_router_nat" "nat" {
  name                               = "${var.app_name}-nat-${var.env_name}"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.private_subnet[*].name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  min_ports_per_vm = 64

  labels = {
    Name = "nat-${var.app_name}"
  }
}

# GCP Routes (default routes are created automatically)
# No need to manually create internet gateways or route tables

# Variables mapping
variable "app_name" {
  description = "Application name"
  type        = string
}

variable "env_name" {
  description = "Environment name (e.g., 'dev', 'prod')"
  type        = string
}

variable "region" {
  description = "GCP region (e.g., 'us-central1')"
  type        = string
}

variable "org_name" {
  description = "Organization name"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones (GCP zones) in the region"
  type        = list(string)
}

variable "container_port" {
  description = "Port that the container listens on"
  type        = number
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}
