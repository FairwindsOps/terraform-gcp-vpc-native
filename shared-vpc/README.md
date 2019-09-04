### shared-vpc modules example parameters
This directory contains two modules intended for use with each other, in order to create VPC intended to be shared. The first module, `network`, simply creates the network resource`, while the second module, `subnetwork`, creates a subnetwork within that network. The subnetwork is configured to create secondary IP alias ranges necessary for VPC-native GKE functionality. 

Each subnetwork is intended for association with an individual service project. You can instantiate the subnetwork module as many times as you'd like within a given network to fit your needs. Just be sure to adjust your names and IP ranges accordingly for no conflicts. 

To use these modules, you'd fill out your `network.tf` like this: 

```
 module "network" {
  source = "git@github.com:FairwindsOps/terraform-gcp-vpc-native//shared-vpc/network?ref=shared-vpc-v0.0.1"
  // base network parameters
  network_name                 = "example-shared-vpc-1"
  region                       = "us-central1"
}
module "staging_subnetwork" {
  source = "git@github.com:FairwindsOps/terraform-gcp-vpc-native//shared-vpc/subnetwork?ref=shared-vpc-v0.0.1"
  // base subnetwork parameters
  shared_vpc                   = "${module.network.shared_vpc}"
  subnetwork_name              = "example-staging-1"
  region                       = "${module.network.region}"
  enable_flow_logs             = "false" 
  //specify the staging subnetwork primary and secondary CIDRs for IP aliasing
  subnetwork_range             = "172.16.0.0/24"
  subnetwork_pods              = "172.16.128.0/17"
  subnetwork_services          = "172.16.64.0/18"
}
module "prod_subnetwork" {
  source = "git@github.com:FairwindsOps/terraform-gcp-vpc-native//shared-vpc/subnetwork?ref=shared-vpc-v0.0.1"
  // base subnetwork parameters
  shared_vpc                   = "${module.network.shared_vpc}"
  subnetwork_name              = "example-production-1"
  region                       = "${module.network.region}"
  enable_flow_logs             = "false"
  //specify the prod subnetwork primary and secondary CIDRs for IP aliasing
  subnetwork_range             = "172.17.0.0/24"
  subnetwork_pods              = "172.17.128.0/17"
  subnetwork_services          = "172.17.64.0/18"
}
```