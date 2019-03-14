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

variable "enable_flow_logs" {
  description = "whether to turn on flow logs or not"
}


#######################
# Create the network and subnetworks, including secondary IP ranges on subnetworks
#######################

resource "google_compute_network" "network" {
  name                    = "${var.network_name}"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = "false"
}

/* note that for secondary ranges necessary for GKE Alias IPs, the ranges have
 to be manually specified with terraform currently -- no GKE automagic allowed here. */
resource "google_compute_subnetwork" "subnetwork" {
  name                     = "${var.subnetwork_name}"
  ip_cidr_range            = "${var.subnetwork_range}"
  network                  = "${google_compute_network.network.self_link}"
  region                   = "${var.region}"
  private_ip_google_access = true
  enable_flow_logs         = "${var.enable_flow_logs}"

  secondary_ip_range = {
    range_name    = "gke-pods-1"
    ip_cidr_range = "${var.subnetwork_pods}"
  }
  secondary_ip_range = {
    range_name    = "gke-services-1"
    ip_cidr_range = "${var.subnetwork_services}"
  }

  /* We ignore changes on secondary_ip_range because terraform doesn't list
  them in the same order every time during runs. */
  lifecycle {
    ignore_changes = [ "secondary_ip_range" ]
  }
}

resource "google_compute_router" "router" {
  name    = "${var.network_name}"
  network = "${google_compute_network.network.name}"
  region  = "${var.region}"
}

resource "google_compute_router_nat" "nat_router" {
  name                               = "${var.network_name}"
  router                             = "${google_compute_router.router.name}"
  region                             = "${var.region}"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

/** provide outputs to be used in GKE cluster creation **/
output "network" {
  value = "${google_compute_network.network.self_link}"
}

output "subnetwork" {
  value = "${google_compute_subnetwork.subnetwork.self_link}"
}

output "router" {
  value = "${google_compute_router.router.self_link}"
}

output "subnetwork_pods" {
  value = "${var.subnetwork_pods}"
}

output "subnetwork_range" {
  value = "${var.subnetwork_range}"
}

/* provide the literal names of the secondary IP ranges for the pods and services.
GKE terraform config needs the names as an input. */
output "gke_pods_1" {
  value = "gke-pods-1"
}

output "gke_services_1" {
  value = "gke-services-1"
}
