### Default module example parameters
The `default` module will create a VPC-native network for Kubernetes clusters. This module can be configured to provision a Cloud NAT gateway. The Cloud NAT gateway can also be configured with `AUTO_ONLY` or `MANUAL_ONLY` options. If `MANUAL_ONLY` is chosen, `cloud_nat_address_count` can be used to select the desired number of public IP addresses.

Fill out your `network.tf` like so:

```
module "network" {
  source = "git@github.com:FairwindsOps/terraform-gcp-vpc-native.git//default?ref=v0.0.1"
  // base network parameters
  network_name               = "project-kube-staging-1"
  subnetwork_name            = "project-staging-1"
  region                     = "us-central1"
  enable_flow_logs           = "false"

  //specify the staging subnetwork primary and secondary CIDRs for IP aliasing
  subnetwork_range    = "10.64.0.0/20"
  subnetwork_pods     = "10.128.0.0/12"
  subnetwork_services = "10.64.32.0/19"

  //optional cloud-nat inputs
  enable_cloud_nat = true
  nat_ip_allocate_option = "MANUAL_ONLY"
  cloud_nat_address_count = 2
}
```
