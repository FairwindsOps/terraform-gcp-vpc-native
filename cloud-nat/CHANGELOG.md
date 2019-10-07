# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## 2.0.0
Note, this module should be considered deprecated. Use the `default` module with cloud-nat options.
### Breaking
* Updated module to support terraform 0.12

## 1.1.0
### Added
* Ability to configure nat router with `var.nat_ip_allocate_option`
* Added `var.cloud_nat_address_count` to specify the number of public NAT IP addresses


## 1.0.0

### deprecations

* The `subnetwork` output is deprecated in favor of the new `subnet_self_link` output.

### Added

* There are new `network_self_link`, `subnetwork_self_link`, and `router_self_link` outputs.
