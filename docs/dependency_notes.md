# Dependency Notes

This repository replaces disallowed utilities with tools from the approved list.

- `rustscan`: Used in `subcase_1b/scripts/trainee_start.sh` to perform port scans instead of `nmap`. Rustscan is an approved scanning utility.
- `timeout` (from `coreutils`): Required by `subcase_1c/scripts/start_cti_component.sh` and `subcase_1c/scripts/start_soc_services.sh` to verify TCP ports using Bash's `/dev/tcp` feature. This replaces `netcat` and keeps the implementation within permitted system utilities.

No additional network tools are necessary; standard systemd and Bash components remain.
