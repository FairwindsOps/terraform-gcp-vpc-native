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

variable "enable_cloud_nat" {
  # https://cloud.google.com/nat/docs/overview#ip_address_allocation
  description = "Setup Cloud NAT gateway for VPC"
  default     = false
}

variable "nat_ip_allocate_option" {
  # https://cloud.google.com/nat/docs/overview#ip_address_allocation
  description = "AUTO_ONLY or MANUAL_ONLY"
  type        = string
  default     = "AUTO_ONLY"
}

variable "cloud_nat_address_count" {
  # https://cloud.google.com/nat/docs/overview#number_of_nat_ports_and_connections
  description = "the count of external ip address to assign to the cloud-nat object"
  type        = number
  default     = 1
}

variable "cloud_nat_min_ports_per_vm" {
  description = "Minimum number of ports allocated to a VM from this NAT."
  type        = number
  default     = 64
}

variable "cloud_nat_tcp_transitory_idle_timeout_sec" {
  # https://cloud.google.com/nat/docs/overview#specs-timeouts
  description = "Timeout in seconds for TCP transitory connections."
  type        = number
  default     = 30
}

variable "cloud_nat_log_config_filter" {
  description = "Specifies the desired filtering of logs on this NAT"
  default     = null
}

variable "subnetwork_flow_logs_enabled" {
  description = "If you want to set up flow logs you will need to set this to enabled and update subnetwork_flow_logs variable defaults if necessary."
  default     = false
}

variable "subnetwork_log_config" {
  /* If any of these need to be overriden, you will need to put the _ENTIRE_ block in your var setting or else you will get an error.
    https://www.terraform.io/docs/providers/google/r/compute_subnetwork.html#example-usage-subnetwork-logging-config */
  description = "settings for subnetwork flow logs"
  default = {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling = 0.5
    metadata = "INCLUDE_ALL_METADATA"
    metadata_fields = []
    filter_expr = ""
  }
}

locals {
  ## the following locals modify resource creation behavior depending on var.nat_ip_allocate_option
  enable_cloud_nat        = var.enable_cloud_nat == true ? 1 : 0
  cloud_nat_address_count = var.nat_ip_allocate_option != "AUTO_ONLY" ? var.cloud_nat_address_count * local.enable_cloud_nat : 0
  nat_ips                 = var.nat_ip_allocate_option != "AUTO_ONLY" ? google_compute_address.ip_address.*.self_link : null
}


#######################
# Create the network and subnetworks, including secondary IP ranges on subnetworks
#######################

resource "google_compute_network" "network" {
  name                    = var.network_name
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

/* note that for secondary ranges necessary for GKE Alias IPs, the ranges have
 to be manually specified with terraform currently -- no GKE automagic allowed here. */
resource "google_compute_subnetwork" "subnetwork" {
  name                     = var.subnetwork_name
  ip_cidr_range            = var.subnetwork_range
  network                  = google_compute_network.network.self_link
  region                   = var.region
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "gke-pods-1"
    ip_cidr_range = var.subnetwork_pods
  }

  secondary_ip_range {
    range_name    = "gke-services-1"
    ip_cidr_range = var.subnetwork_services
  }

  dynamic "log_config" {
    /* this confusing for_each block only allows a single log_config element instead of a true loop.
     This is because we are just shoving the single map 'subnetwork_log_config' into a list.
     I believe this is the only way to get a conditional block. */
    for_each = var.subnetwork_flow_logs_enabled == false ? [] : [var.subnetwork_log_config]
    content {
      aggregation_interval = log_config.value["aggregation_interval"]
      flow_sampling        = log_config.value["flow_sampling"]
      metadata             = log_config.value["metadata"]
      metadata_fields      = log_config.value["metadata_fields"] == [] ? null : log_config.value["metadata_fields"]
      filter_expr          = log_config.value["filter_expr"] == "" ? null : log_config.value["filter_expr"]
    }
  }

  /* We ignore changes on secondary_ip_range because terraform doesn't list
    them in the same order every time during runs. */
  lifecycle {
    ignore_changes = [secondary_ip_range]
  }
}

resource "google_compute_router" "router" {
  count   = local.enable_cloud_nat
  name    = var.network_name
  network = google_compute_network.network.name
  region  = var.region
}

resource "google_compute_address" "ip_address" {
  count  = local.cloud_nat_address_count
  name   = "nat-external-address-${count.index}"
  region = var.region
}

resource "google_compute_router_nat" "nat_router" {
  count                              = local.enable_cloud_nat
  name                               = var.network_name
  router                             = google_compute_router.router.0.name
  region                             = var.region
  nat_ip_allocate_option             = var.nat_ip_allocate_option
  nat_ips                            = local.nat_ips
  min_ports_per_vm                   = var.cloud_nat_min_ports_per_vm
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  tcp_transitory_idle_timeout_sec    = var.cloud_nat_tcp_transitory_idle_timeout_sec

  log_config {
    enable = var.cloud_nat_log_config_filter == null ? false : true
    filter = var.cloud_nat_log_config_filter == null ? "ALL" : var.cloud_nat_log_config_filter
  }
}

/** provide outputs to be used in GKE cluster creation **/
output "network_self_link" {
  value = google_compute_network.network.self_link
}

output "subnetwork" {
  value = google_compute_subnetwork.subnetwork.self_link
}

output "subnetwork_self_link" {
  value = google_compute_subnetwork.subnetwork.self_link
}

output "router_self_link" {
  value = local.enable_cloud_nat == 1 ? google_compute_router.router.*.self_link : null
}

output "subnetwork_pods" {
  value = var.subnetwork_pods
}

output "subnetwork_range" {
  value = var.subnetwork_range
}

/* provide the literal names of the secondary IP ranges for the pods and services.
GKE terraform config needs the names as an input. */
output "gke_pods_1" {
  value = "gke-pods-1"
}

output "gke_services_1" {
  value = "gke-services-1"
}

