# Ansible Playbooks for Subcase 1c

These playbooks deploy BIPS, CICMS, CTEMS, NG-SIEM, and NG-SOC components.

## Variables

- `ngsoc_repo_url`: Base URL for NG-SOC package repository. Defaults to `https://packages.internal.example.com`. Override in inventory or group vars to use environment-specific repositories.

## Malware simulation scripts

The CTEMS role deploys PowerShell scripts used for generating benign telemetry. The
`benign_malware_simulator.ps1` script is now sourced from the shared
`../scripts/` directory instead of a copy bundled with the role. Update that
script in `subcase_1c/scripts/` to change the simulator used by CTEMS.
