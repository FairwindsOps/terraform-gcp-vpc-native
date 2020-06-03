# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## 2.2.2

### Added
* added variable for `cloud_nat_tcp_transitory_idle_timeout_sec`
## 2.2.1

### Fixed
* updated the log_config logic to prevent changes on each run

## 2.2.0

### Added
* added variable for `min_ports_per_vm`
* added variable `cloud_nat_log_config_filter`

### Removed
* removed unused variable `enable_flow_logs`

## 2.1.0

### Removed
* `enable_flow_logs` has been deprecated and removed

## 2.0.0
### Breaking

* Upgraded module to support terraform 0.12.x
### Added
* Added Cloud NAT support. See docs for new inputs and logic.

## 1.0.1

### deprecations

* The `subnetwork` output is deprecated in favor of the new `subnet_self_link` output.

### Added

* There are new `network_self_link` and `subnetwork_self_link` outputs.
* A network_description variable has been added, which is used as an argument to provide a description on `google_compute_network`. This is optional and defaults to null.

## 1.0.0

## Added

* Initial release of the `default` module, which features public networking and VPC-native functionality.