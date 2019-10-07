#######################
# Define all the variables we'll need
#######################

variable "network_name" {
  description = "the name of the network"
}

variable "region" {
  description = "region to use"
}

#######################
# Create the network and subnetworks, including secondary IP ranges on subnetworks
#######################

resource "google_compute_network" "shared_vpc" {
  name                    = var.network_name
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = "false"
}

#######################
# Provide outputs to be used in subnetwork and GKE cluster creation
#######################
output "shared_vpc" {
  value = google_compute_network.shared_vpc.self_link
}

output "region" {
  description = "The region in which this network exists"
  value       = var.region
}

