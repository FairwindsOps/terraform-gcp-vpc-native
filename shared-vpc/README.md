### shared-vpc module example parameters
This `shared-vpc` module is similar to the `default`module, but is intended for use with the [terraform-gcp-gke-shared-vpc](https://github.com/FairwindsOps/terraform-gcp-gke-shared-vpc) module. It provides two subnetworks, called `staging` and `prod`, within one VPC. Each subnetwork is intended for association with an individual service project.

To use the `shared-vpc` module, you'd fill out your `network.tf` like so: 

```
module "network" {
  source = "git@github.com:FairwindsOps/terraform-gcp-vpc-native//shared-vpc?ref=shared-vpc-v0.0.1"
  // base network parameters
  network_name                 = "example-shared-vpc-1"
  staging_subnetwork_name      = "example-staging-1"
  prod_subnetwork_name         = "example-production-1"
  region                       = "us-central1"
  enable_flow_logs             = "false"

  // specify the staging subnetwork primary and secondary CIDRs for IP aliasing
  staging_subnetwork_range     = "172.16.0.0/24"
  staging_subnetwork_pods      = "172.16.128.0/17"
  staging_subnetwork_services  = "172.16.64.0/18"

  // specify the staging subnetwork primary and secondary CIDRs for IP aliasing
  prod_subnetwork_range        = "172.17.0.0/24"
  prod_subnetwork_pods         = "172.17.128.0/17"
  prod_subnetwork_services     = "172.17.64.0/18"
}
```