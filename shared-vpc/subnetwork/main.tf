variable "shared_vpc" {
  description = "self_link of the shared vpc to create subnetwork in"
}

variable "region" {
  description = "region to use"
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
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
    metadata_fields      = []
    filter_expr          = ""
  }
}

/* note that for secondary ranges necessary for GKE Alias IPs, the ranges have
 to be manually specified with terraform currently -- no GKE automagic allowed here. */
resource "google_compute_subnetwork" "subnetwork" {
  name                     = var.subnetwork_name
  ip_cidr_range            = var.subnetwork_range
  network                  = var.shared_vpc
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

