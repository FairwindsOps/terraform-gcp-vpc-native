# Terraform GCP VPC-Native Network Module
This repository contains the standards for GKE cluster implementations, and is a work in progress. The GKE cluster module should be adaptable. Ideally, it should allow for public "standard" GKE clusters, public/VPC-native clusters, and private/VPC-native clusters. This module will only contain GKE-related terraform resources. Underlying network resources will be created in separate modules in separate repositories, which will have to be used in conjunction with this module/repository to create a complete infrastructure. [add links to these network module repos as they are created]

This repository contains VPC configuration intended for use with public VPC-native GKE clusters created with the [terraform-gke](https://github.com/reactiveops/terraform-gke) module. It will create a VPC, a CI subnet, a staging subnet, and a production subnet with all necessary secondary ranges for each to be used by GKE. 

## Usage
* Expand on the parameters necessary for spin-up
* Short details on spinning up with terraform and viewing outputs necessary for the `terraform-gke` module. 

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