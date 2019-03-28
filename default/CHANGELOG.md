# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## 1.0.1

### deprecations

* The `subnetwork` output is deprecated in favor of the new `subnet_self_link` output.

### Added

* There are new `network_self_link` and `subnetwork_self_link` outputs.
* A network_description variable has been added, which is used as an argument to provide a description on `google_compute_network`. This is optional and defaults to null.

## 1.0.0

## Added

* Initial release of the `default` module, which features public networking and VPC-native functionality.