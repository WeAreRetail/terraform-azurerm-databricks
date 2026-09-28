<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.1.0]

### Added

- Optional `storage_private_endpoint` input to create blob and dfs private endpoints to the Databricks DBFS storage account.

## [3.0.0]

### Breaking change

- Update to azurerm 5 and migrate subnet service endpoints to blocks.

## [2.0.2] - 2025-01-06

# Fixes

Changed constraint for random provider as it should not be a pinned version.

## [2.0.1] - 2024-09-12

# Fixes

Reproduce old behavior: `private_endpoint_network_policies` = "Enabled"

## [2.0.0] - 2024-09-11

### Breaking change

- Update to azurerm 4

## [1.1.0] - 2024-03-25

### Added

- List of service endpoint to enable on the databricks virtual networks

## [1.0.0] - 2024-03-01

### Added

- Initial Release
- Changed storage account to weareretail registry module instead
