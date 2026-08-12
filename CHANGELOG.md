# Changelog

## [2.0.0](https://github.com/max-pfeiffer/proxmox-talos-opentofu/compare/1.4.0...2.0.0) (2026-08-12)


### ⚠ BREAKING CHANGES

* made hostnames configurable

### Features

* made hostnames configurable ([d7adedb](https://github.com/max-pfeiffer/proxmox-talos-opentofu/commit/d7adedbe4c2fc1c6b638d4a17dba60f8d0cdfa2d))
* updated Talos and Kubernetes versions ([1f6c8a1](https://github.com/max-pfeiffer/proxmox-talos-opentofu/commit/1f6c8a196e6b45193d7d37dff8293e740c6202c1))
* upgraded Talos provider and switched to new talos_machine resource ([b69ac71](https://github.com/max-pfeiffer/proxmox-talos-opentofu/commit/b69ac716286091755276986187df372fd144a4f0))


### Bug Fixes

* made hubble installation stable when generating the config for C… ([f642ad7](https://github.com/max-pfeiffer/proxmox-talos-opentofu/commit/f642ad7a2d0d5ad3acadecd5366391773018765f))
* made hubble installation stable when generating the config for Cilium Helm chart ([fb8e5bd](https://github.com/max-pfeiffer/proxmox-talos-opentofu/commit/fb8e5bd018fa5b132c0d4bb5bf5c38765a50ae11))


### Documentation

* explaining the in-place node upgrade procedure ([74b87b8](https://github.com/max-pfeiffer/proxmox-talos-opentofu/commit/74b87b858059212cda17098e938c27eb4f4c91b7))

## [1.4.0](https://github.com/max-pfeiffer/proxmox-talos-opentofu/compare/1.3.0...1.4.0) (2026-08-09)


### Features

* Added pre-commit tool and git hooks ([38d057c](https://github.com/max-pfeiffer/proxmox-talos-opentofu/commit/38d057ce8ceebb5c4bd7915fd4cc404d915a9990))
* Added release-please config and GitHub workflows for qa and automated releases ([3036f34](https://github.com/max-pfeiffer/proxmox-talos-opentofu/commit/3036f3435498abf97257c07c9a7325c09a4b16cd))
* resources are configurable for each node: cpu, ram, disk space ([7cf2ce4](https://github.com/max-pfeiffer/proxmox-talos-opentofu/commit/7cf2ce4ee29ba79c5a694ccd44c43d636c9dedcc))
