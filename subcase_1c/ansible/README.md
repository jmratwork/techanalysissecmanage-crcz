# Ansible Playbooks for Subcase 1c

These playbooks deploy BIPS, CICMS, CTEMS, NG-SIEM, and NG-SOC components.

## Variables

- `ngsoc_repo_url`: Base URL for NG-SOC package repository. Defaults to `https://packages.internal.example.com`. Override in inventory or group vars to use environment-specific repositories.
