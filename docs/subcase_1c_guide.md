# Subcase 1c Guide: Malware Simulation and CTI Integration

## Objective
Simulate benign malware activity and integrate threat intelligence feeds to exercise NG-SOC components.

## Tasks

1. **Start SOC services**
   ```bash
   sudo subcase_1c/scripts/start_soc_services.sh
   ```
   Launches BIPS, NG-SIEM, CICMS, and NG-SOC.
   Port checks rely on Bash's `/dev/tcp` and `timeout` rather than `netcat`.

2. **Start CTI component and ingest feeds**
   ```bash
   sudo subcase_1c/scripts/start_cti_component.sh
   ```
   Runs MISP, starts the `fetch-cti-feed` systemd service, and verifies NG-SIEM.
   Port verification uses the same built-in method to avoid disallowed tools.
   Use `CTI_OFFLINE=1` or run the fetch script with `--offline` to skip external
   downloads when network access is unavailable.

3. **Launch the C2 server**  
   ```bash
   sudo subcase_1c/scripts/start_c2_server.sh
   ```

4. **Execute the malware simulation on a Windows host**
   ```powershell
   $env:BEACON_URL = "http://localhost:5601/beacon"  # optional override
   .\subcase_1c\scripts\benign_malware_simulator.ps1 -BeaconCount 3
   ```
   The beacon URL can also be set directly via the `-BeaconUrl` parameter:
   ```powershell
   .\subcase_1c\scripts\benign_malware_simulator.ps1 -BeaconCount 3 -BeaconUrl http://ng-siem.local/beacon
   ```
   or load via [`load_malware_simulation.ps1`](../subcase_1c/scripts/load_malware_simulation.ps1).

5. **Observe telemetry in NG-SOC tools**  
   Monitor BIPS, NG-SIEM, CICMS, NG-SOC, and MISP for beacons, file drops, and CTI correlations.

## Expected Outcomes

- SOC services accessible on ports 5500 (BIPS), 5601 (NG-SIEM), 5800 (CICMS), and 5900 (NG-SOC).
- MISP running on port 8443 with threat feed ingested.
- C2 server responding on port 9001.
- Benign malware simulator generates HTTP beacons and file artifacts detected by NG-SOC components.

## References

- [`start_soc_services.sh`](../subcase_1c/scripts/start_soc_services.sh)
- [`start_cti_component.sh`](../subcase_1c/scripts/start_cti_component.sh)
- [`fetch-cti-feed.service`](../subcase_1c/ansible/roles/misp/templates/fetch-cti-feed.service.j2)
- [`start_c2_server.sh`](../subcase_1c/scripts/start_c2_server.sh)
- [`benign_malware_simulator.ps1`](../subcase_1c/scripts/benign_malware_simulator.ps1)
- [`load_malware_simulation.ps1`](../subcase_1c/scripts/load_malware_simulation.ps1)
- [NG-SOC components matrix](ngsoc_components_matrix.md)

