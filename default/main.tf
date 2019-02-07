#######################
# Define all the variables we'll need
#######################

variable "network_name" {
  description = "the name of the network"
}

variable "subnetwork_name" {
  description = "name for the subnetwork"
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

variable "region" {
  description = "region to use"
}



#######################
# Create the network and subnetworks, including secondary IP ranges on subnetworks
#######################

resource "google_compute_network" "network" {
  name                    = "${var.network_name}"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = "false"
}

/* note that for secondary ranges necessary for GKE Alias IPs, the ranges have to be manually specificied
   with terraform currently -- no GKE automagic allowed here. We ignore changes on secondary_ip_range 
   because terraform doesn't list them in the same order every time during runs. */

resource "google_compute_subnetwork" "subnetwork" {
  name          = "${var.subnetwork_name}"
  ip_cidr_range = "${var.subnetwork_range}"
  network       = "${google_compute_network.network.self_link}"
  region        = "${var.region}"
  private_ip_google_access = true

  secondary_ip_range = {
    range_name = "gke-pods-1"
    ip_cidr_range = "${var.subnetwork_pods}"
  }
  secondary_ip_range = {
    range_name = "gke-services-1"
    ip_cidr_range = "${var.subnetwork_services}"
  }

  lifecycle {
    ignore_changes = [ "secondary_ip_range" ]
  }
}
/** provide outputs to be used in GKE cluster creation **/
/* network details */
output "subnetwork" {
  value = "${google_compute_subnetwork.subnetwork.self_link}"
}

output "subnetwork_pods" {
  value = "${var.subnetwork_pods}"
}

output "subnetwork_range" {
  value = "${var.subnetwork_range}"
}

output "gke_pods_1" {
  value = "gke-pods-1"
}

output "gke_services_1" {
  value = "gke-services-1"
}