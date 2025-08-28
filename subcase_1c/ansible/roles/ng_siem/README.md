# NG-SIEM role

This role configures NG-SIEM components.

## Variables

- `ng_siem_collector_host`: Hostname or IP address of the NG-SIEM collector that receives Beat events.
- `ng_siem_collector_port`: TCP port on which the NG-SIEM collector listens. Defaults to `5044` if not set.
