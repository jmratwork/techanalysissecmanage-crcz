# Provisioning Subcase 1b Packages

This directory contains example automation for provisioning the subcase 1b sandbox. The NG-SOC
components are distributed through a private APT repository. Each host installs the required
package from this repository, or alternatively, container images can be used.

## Package locations

| Component | Deb package URL | Container image |
|-----------|-----------------|-----------------|
| BIPS | https://ngsoc.example.com/apt/pool/bips/bips-agent.deb | registry.example.com/ngsoc/bips:latest |
| NG-SIEM | https://ngsoc.example.com/apt/pool/ng-siem/ng-siem-server.deb | registry.example.com/ngsoc/ng-siem:latest |
| CICMS | https://ngsoc.example.com/apt/pool/cicms/cicms-server.deb | registry.example.com/ngsoc/cicms:latest |
| NG-SOC | https://ngsoc.example.com/apt/pool/ng-soc/ng-soc-platform.deb | registry.example.com/ngsoc/ng-soc:latest |

## Adding the private APT repository

The playbook in this folder adds the repository automatically, but manual setup can be performed
as follows:

```bash
echo 'deb [trusted=yes] https://ngsoc.example.com/apt stable main' | \
  sudo tee /etc/apt/sources.list.d/ngsoc.list
sudo apt-get update
sudo apt-get install bips ng-siem cicms ng-soc
```

These packages provide the services required by the BIPS, NG‑SIEM, CICMS and NG‑SOC hosts during
sandbox provisioning.
