# Terraform GCP VPC-Native Network Module
This repository contains VPC configuration intended for use with VPC-native GKE clusters created with the [terraform-gke](https://github.com/FairwindsOps/terraform-gke) module. The `default` directory contains a standard VPC module intended for use with VPC-native GKE clusters, which has public networking.

## How to source modules from this repository
* Just add a `network.tf` file to the `terraform` directory of your inventory item that sources the module:
```
.
├── inventory
│   └── staging
│       ├── config
│       └── terraform
            ├── backend.tf
            ├── network.tf <-- add this file
            └── provider.tf
```

See the individual module's README.md for an example of sourcing it (including all parameters to define.) 

### Secondary range notes
To set up a VPC-native cluster, you have to configure two secondary ranges for each subnetwork in addition to the standard subnet range. One secondary range is used for allocating IP addresses to pods while the other is used for allocating IP addresses to cluster services.  With this module, you specify these ranges as `subnetwork_range`, `subnetwork_pods`, and `subnetwork_services`. `subnetwork_range` is the range of IP addresses for the GKE nodes themselves; `subnetwork_pods` is the range of IP addresses for the pods; `subnetwork_services` is the range for Kubernetes cluster services.

The example ranges given above are a good default size -- it allows for 4,092 nodes, 4,092 services, and 16,382 pods per subnetwork in the subnetwork. Refer to Google Cloud's docs [here](https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips) on other sizing options. The ranges given do not have to be contiguous, but they must not overlap.


## Contributing
See [CONTRIBUTING.md](./CONTRIBUTING.md).

## Release Expectations
We intend to use semantic versioning for the modules in this repository. This means that each module folder will have a release tag similar to `module-name:v0.0.1`. We never intend any versions to 
recreate the network, since this could result in state loss for the GKE clusters built on this. If any modules are made completely incompatible we will note in release notes. If any compatibility issues are found in the wild, please submit an issue with a way to recreate the scenario.

Each module should have it's own usage documentation in the folder. The module folder should also include a `CHANGELOG.md` for that module.

We do not anticipate retrofitting patches to older MINOR versions. If we are currently on v1.2.0 and a bug is found that was introduced in v1.1.0 we will patch to v1.2.1 (and there will not be a v1.1.1). Pull requests always accepted if you have a need to patch older releases.

### Version Differences
* MAJOR: Changing versions here will require changes to your module parameters
  * Could have new **required** parameters or changes to defaults that could affect implementations
  * May remove certain parameters
  * Will not re-provision your cluster, unless noted in the changelog release notes
* MINOR: Changing minor versions should have parameter backwards compatibility
  * **Required** parameters should not change between MINOR versions
  * _Optional_ parameters may change or there may be new _optional_ parameters
  * We will **not remove _optional_ parameters** between MINOR releases, a MAJOR is required
  * Defaults on _optional_ parameters **may change** between MINOR versions, including default versions or other cluster settings
  * Change Log will outline expected differences between Minor releases
* PATCH: Changing minor defaults or logic fixes
  * Bugs that fix behavior or adjust "constant change" issues in terraform runs
  * Typos could be fixed with patch if it affects behavior of the terraform module
  * Fixes to older supported features of the module that broke with MINOR functionality changes
  * README and USAGE documentation changes may trigger a PATCH change and should be documented in CHANGELOG


## Join the Fairwinds Open Source Community

The goal of the Fairwinds Community is to exchange ideas, influence the open source roadmap, and network with fellow Kubernetes users. [Chat with us on Slack](https:\/\/join.slack.com\/t\/fairwindscommunity\/shared_invite\/zt-e3c6vj4l-3lIH6dvKqzWII5fSSFDi1g) or [join the user group](https:\/\/www.fairwinds.com\/open-source-software-user-group) to get involved!


## Other Projects from Fairwinds

Enjoying terraform-gcp-vpc-native? Check out some of our other projects:
* [Polaris](https://github.com/FairwindsOps/Polaris) - Audit, enforce, and build policies for Kubernetes resources, including over 20 built-in checks for best practices
* [Goldilocks](https://github.com/FairwindsOps/Goldilocks) - Right-size your Kubernetes Deployments by compare your memory and CPU settings against actual usage
* [Pluto](https://github.com/FairwindsOps/Pluto) - Detect Kubernetes resources that have been deprecated or removed in future versions
* [Nova](https://github.com/FairwindsOps/Nova) - Check to see if any of your Helm charts have updates available
* [rbac-manager](https://github.com/FairwindsOps/rbac-manager) - Simplify the management of RBAC in your Kubernetes clusters

Or [check out the full list](https://www.fairwinds.com/open-source-software?utm_source=terraform-gcp-vpc-native&utm_medium=terraform-gcp-vpc-native&utm_campaign=terraform-gcp-vpc-native)
