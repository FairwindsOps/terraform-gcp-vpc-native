#######################
# Define all the variables we'll need
#######################

variable "network_name" {
  description = "the name of the network"
}

variable "enable_flow_logs" {
  description = "whether to turn on flow logs or not"
}

variable "region" {
  description = "region to use"
}

variable "staging_subnetwork_name" {
  description = "name for the staging subnetwork"
}

variable "staging_subnetwork_range" {
  description = "CIDR for staging subnetwork nodes"
}

variable "staging_subnetwork_pods" {
  description = "secondary CIDR for pods"
}

variable "staging_subnetwork_services" {
  description = "secondary CIDR for services"
}

variable "prod_subnetwork_name" {
  description = "name for the production subnetwork"
}

variable "prod_subnetwork_range" {
  description = "CIDR for prod subnetwork nodes"
}

variable "prod_subnetwork_pods" {
  description = "secondary CIDR for pods"
}

variable "prod_subnetwork_services" {
  description = "secondary CIDR for services"
}


#######################
# Create the network and subnetworks, including secondary IP ranges on subnetworks
#######################

resource "google_compute_network" "shared_vpc" {
  name                    = "${var.network_name}"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = "false"
}

/* note that for secondary ranges necessary for GKE Alias IPs, the ranges have
 to be manually specified with terraform currently -- no GKE automagic allowed here. */
resource "google_compute_subnetwork" "prod_subnetwork" {
  name                     = "${var.prod_subnetwork_name}"
  ip_cidr_range            = "${var.prod_subnetwork_range}"
  network                  = "${google_compute_network.shared_vpc.self_link}"
  region                   = "${var.region}"
  private_ip_google_access = true
  enable_flow_logs         = "${var.enable_flow_logs}"
  secondary_ip_range = {
    range_name = "gke-pods-1"
    ip_cidr_range = "${var.prod_subnetwork_pods}"
  }
  secondary_ip_range = {
    range_name = "gke-services-1"
    ip_cidr_range = "${var.prod_subnetwork_services}"
  }

  /* We ignore changes on secondary_ip_range because terraform doesn't list
    them in the same order every time during runs. */
  lifecycle {
    ignore_changes = [ "secondary_ip_range" ]
  }
}

resource "google_compute_subnetwork" "staging_subnetwork" {
  name          = "${var.staging_subnetwork_name}"
  ip_cidr_range = "${var.staging_subnetwork_range}"
  network       = "${google_compute_network.shared_vpc.self_link}"
  region        = "${var.region}"
  secondary_ip_range = {
    range_name = "gke-pods-1"
    ip_cidr_range = "${var.staging_subnetwork_pods}"
  }
  secondary_ip_range = {
    range_name = "gke-services-1"
    ip_cidr_range = "${var.staging_subnetwork_services}"
  }

  lifecycle {
    ignore_changes = [ "secondary_ip_range" ]
  }
}
/** provide outputs to be used in GKE cluster creation **/
output "shared_vpc" {
  value = "${google_compute_network.shared_vpc.self_link}"
}

/* production network details */
output "prod_subnetwork" {
  value = "${google_compute_subnetwork.prod_subnetwork.self_link}"
}

output "prod_subnetwork_pods" {
  value = "${var.prod_subnetwork_pods}"
}

output "prod_gke_pods_1" {
  value = "gke-pods-1"
}

output "prod_gke_services_1" {
  value = "gke-services-1"
}

/*staging network details */
output "staging_subnetwork" {
  value = "${google_compute_subnetwork.staging_subnetwork.self_link}"
}

output "staging_subnetwork_pods" {
  value = "${var.staging_subnetwork_pods}"
}

output "staging_gke_pods_1" {
  value = "gke-pods-1"
}

output "staging_gke_services_1" {
  value = "gke-services-1"
}
