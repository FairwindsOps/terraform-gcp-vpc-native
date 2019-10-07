variable "shared_vpc" {
  description = "self_link of the shared vpc to create subnetwork in"
}

variable "region" {
  description = "region to use"
}

variable "subnetwork_name" {
  description = "name for the subnetwork"
}

variable "enable_flow_logs" {
  description = "whether to turn on flow logs or not"
}

variable "subnetwork_range" {
  description = "CIDR for subnetwork nodes"
}

variable "subnetwork_pods" {
  description = "secondary CIDR for pods"
}

variable "subnetwork_services" {
  description = "secondary CIDR for services"
}

/* note that for secondary ranges necessary for GKE Alias IPs, the ranges have
 to be manually specified with terraform currently -- no GKE automagic allowed here. */
resource "google_compute_subnetwork" "subnetwork" {
  name                     = var.subnetwork_name
  ip_cidr_range            = var.subnetwork_range
  network                  = var.shared_vpc
  region                   = var.region
  private_ip_google_access = true
  enable_flow_logs         = var.enable_flow_logs
  secondary_ip_range {
    range_name    = "gke-pods-1"
    ip_cidr_range = var.subnetwork_pods
  }
  secondary_ip_range {
    range_name    = "gke-services-1"
    ip_cidr_range = var.subnetwork_services
  }

  /* We ignore changes on secondary_ip_range because terraform doesn't list
    them in the same order every time during runs. */
  lifecycle {
    ignore_changes = [secondary_ip_range]
  }
}

#######################
# Provide outputs to be used in GKE cluster creation
#######################
output "subnetwork" {
  value = google_compute_subnetwork.subnetwork.name
}

output "subnetwork_pods" {
  value = var.subnetwork_pods
}

output "gke_pods_1" {
  value = "gke-pods-1"
}

output "gke_services_1" {
  value = "gke-services-1"
}

