> :warning: **This module has been deprecated. Please use [the `default` module](../default/README.md) and supply the `enable_cloud_nat = true` argument instead.**

### Cloud NAT module example parameters
The `cloud-nat` module is similar to the `default` module, but it additionally creates a Cloud Router and Cloud NAT. Cloud NAT is a managed offering that provides a managed NAT gateway for the network. You can use this module to build a VPC-native GKE cluster with private nodes that have no public IP addresses. Internet traffic from the nodes is routed through the Cloud NAT.

The set up is the same as for the default module. You'd fill out the network.tf like so, specifying the path of the cloud-nat module instead:

```terraform
module "network" {
  source = "git@github.com:FairwindsOps/terraform-gcp-vpc-native.git//cloud-nat?ref=cloud-nat-v1.1.0"
  // base network parameters
  network_name               = "project-kube-staging-1"
  subnetwork_name            = "project-staging-1"
  region                     = "us-central1"
  enable_flow_logs           = "false"

  //specify the staging subnetwork primary and secondary CIDRs for IP aliasing
  subnetwork_range     = "10.128.0.0/20"
  subnetwork_pods      = "10.128.64.0/18"
  subnetwork_services  = "10.128.32.0/20"

  // Optional Variables 
  // AUTO_ONLY or MANUAL_ONLY NAT allocation
  nat_ip_allocate_option = "MANUAL_ONLY"
  cloud_nat_address_count = 2
}
```
