# Subcase 1c Guide: Malware Simulation and CTI Integration

See [deployment manual](deployment_manual.md) for baseline environment setup and teardown steps before running this scenario.

This guide walks through deploying the Subcase 1c environment, running the
benign malware simulator, and validating that NG‑SOC components respond as
expected.

## Deployment

1. **Start SOC services**

   ```bash
   sudo subcase_1c/scripts/start_soc_services.sh
   ```

   Launches BIPS, NG‑SIEM, CICMS, NG‑SOC, Decide, and Act. Port checks rely on
   Bash's `/dev/tcp` and `timeout` rather than external utilities.

2. **Start CTI component and ingest feeds**

   ```bash
   sudo subcase_1c/scripts/start_cti_component.sh
   ```

   Runs MISP, starts the `fetch-cti-feed` systemd service, and verifies
   NG‑SIEM. Use `CTI_OFFLINE=1` or run the fetch script with `--offline` to
   skip external downloads when network access is unavailable.

3. **Launch the C2 server**

   ```bash
   sudo subcase_1c/scripts/start_c2_server.sh
   ```

4. **Configure malware detection rules**

   YARA rules live in `subcase_1c/malware_detection/rules/`. Add or adjust
   rules in this directory and scan samples with:

   ```bash
   python subcase_1c/malware_detection/scanner.py <sample>
   ```

5. **Validate playbooks**

   Act consumes CACAO‑style playbooks from `subcase_1c/playbooks/` for actions
   such as host isolation or malware eradication. Validate the playbooks
   before use:

   ```bash
   python subcase_1c/scripts/validate_playbooks.py
   ```

## Attack Simulation

1. **Execute the malware simulation on a Windows host**

   ```powershell
   $env:BEACON_URL = "http://localhost:5601/beacon"  # optional override
   .\subcase_1c\scripts\benign_malware_simulator.ps1 -BeaconCount 3
   ```

   The beacon URL can also be set directly via the `-BeaconUrl` parameter:

   ```powershell
   .\subcase_1c\scripts\benign_malware_simulator.ps1 -BeaconCount 3 -BeaconUrl http://ng-siem.local/beacon
   ```

   or load via
   [`load_malware_simulation.ps1`](../subcase_1c/scripts/load_malware_simulation.ps1).

2. **Observe telemetry in NG‑SOC tools**

   Monitor BIPS, NG‑SIEM, CICMS, NG‑SOC, and MISP for beacons, file drops, and
   CTI correlations.

3. **Verify alerts in NG‑SIEM dashboards**

   - Open Kibana at `http://localhost:5602`.
   - In *Discover*, search for `BenignMalwareSim` to confirm log ingestion from
     Filebeat and Winlogbeat.
   - In the *Security* app, ensure beacon activity from the simulator appears as
     alerts.

4. **Analyst login and triage alerts**

   - Browse to the Kibana dashboard at `http://localhost:5602`.
  - Log in with analyst credentials.
  - Review alerts in the *Security* app and mark them as acknowledged.
  - Acknowledgement can also be recorded via the Act API:

     ```bash
    curl -X POST http://localhost:8100/acknowledge \
         -H 'Content-Type: application/json' \
         -d '{"alert_id": "abc123", "analyst": "analyst"}'
    ```

   Analysts can reference the [SOC Analyst Playbook](soc_analyst_playbook.md) for deeper guidance on navigation, search queries, and alert confirmation.

5. **Verify BIPS alerts**

   Check each BIPS alert to ensure it reflects real activity:

   - Cross-reference the alert indicators with MISP to confirm known threats.
   - Inspect the affected host for related processes, files, or registry changes.
   - Review NG-SIEM and network telemetry to validate event correlation.
   - Compare with benign malware simulator logs to rule out false positives.

6. **Record confirmation in CICMS/Act**

   Analysts document verified alerts in the CICMS case record and update Act
   to mark the alert as confirmed:

   ```bash
   curl -X POST http://localhost:8100/confirm \
        -H 'Content-Type: application/json' \
        -d '{"alert_id": "abc123", "status": "confirmed"}'
   ```

## Validation

1. **Request mitigation guidance and apply response**

   ```bash
   python3 subcase_1c/scripts/apply_mitigation.py 192.0.2.10 --source ng-siem --severity 5
   ```

   The script contacts the Act service, which queries Decide for a
   recommendation and executes the suggested mitigation on the target.

2. **Confirm component status**

   - SOC services accessible on ports 5500 (BIPS), 5601 (NG‑SIEM), 5602 (Kibana
     UI), 5800 (CICMS), 5900 (NG‑SOC), 8000 (Decide), and 8100 (Act).
   - MISP running on port 8443 with threat feed ingested.
   - C2 server responding on port 9001.
   - Benign malware simulator generates HTTP beacons and file artifacts detected
     by NG‑SOC components.

## References

- [`start_soc_services.sh`](../subcase_1c/scripts/start_soc_services.sh)
- [`start_cti_component.sh`](../subcase_1c/scripts/start_cti_component.sh)
- [`bips_start.sh`](../subcase_1c/scripts/bips_start.sh)
- [`fetch-cti-feed.service`](../subcase_1c/ansible/roles/misp/templates/fetch-cti-feed.service.j2)
- [`start_c2_server.sh`](../subcase_1c/scripts/start_c2_server.sh)
- [`apply_mitigation.py`](../subcase_1c/scripts/apply_mitigation.py)
- [`benign_malware_simulator.ps1`](../subcase_1c/scripts/benign_malware_simulator.ps1)
- [`load_malware_simulation.ps1`](../subcase_1c/scripts/load_malware_simulation.ps1)
- [NG‑SOC components matrix](ngsoc_components_matrix.md)

