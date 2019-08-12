### Default module example parameters
To use the `default` module with a VPC-native-ready public network, you'd fill out your `network.tf` like so: 

```
module "network" {
  source = "git@github.com:FairwindsOps/terraform-gcp-vpc-native.git//default?ref=v0.0.1"
  // base network parameters
  network_name               = "project-kube-staging-1"
  subnetwork_name            = "project-staging-1"
  region                     = "us-central1"
  enable_flow_logs           = "false"

  //specify the staging subnetwork primary and secondary CIDRs for IP aliasing
  subnetwork_range     = "10.128.0.0/20"
  subnetwork_pods      = "10.128.64.0/18"
  subnetwork_services  = "10.128.32.0/20"

}
```