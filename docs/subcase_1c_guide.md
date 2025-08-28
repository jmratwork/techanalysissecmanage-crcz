# Subcase 1c Guide: Malware Simulation and CTI Integration

## Objective
Simulate benign malware activity and integrate threat intelligence feeds to exercise NG-SOC components.

## Tasks

1. **Start SOC services**  
   ```bash
   sudo subcase_1c/scripts/start_soc_services.sh
   ```  
   Launches BIPS, NG-SIEM, CICMS, and NG-SOC.

2. **Start CTI component and ingest feeds**  
   ```bash
   sudo subcase_1c/scripts/start_cti_component.sh
   ```  
   Runs CTEMS, kicks off [fetch_cti_feed.sh](../subcase_1c/scripts/fetch_cti_feed.sh), and verifies NG-SIEM.

3. **Launch the C2 server**  
   ```bash
   sudo subcase_1c/scripts/start_c2_server.sh
   ```

4. **Execute the malware simulation on a Windows host**  
   ```powershell
   .\subcase_1c\scripts\benign_malware_simulator.ps1 -BeaconCount 3
   ```
   or load via [`load_malware_simulation.ps1`](../subcase_1c/scripts/load_malware_simulation.ps1).

5. **Observe telemetry in NG-SOC tools**  
   Monitor BIPS, NG-SIEM, CICMS, NG-SOC, and CTEMS for beacons, file drops, and CTI correlations.

## Expected Outcomes

- SOC services accessible on ports 5500 (BIPS), 5601 (NG-SIEM), 5800 (CICMS), and 5900 (NG-SOC).
- CTEMS running on port 5700 with threat feed ingested.
- C2 server responding on port 9001.
- Benign malware simulator generates HTTP beacons and file artifacts detected by NG-SOC components.

## References

- [`start_soc_services.sh`](../subcase_1c/scripts/start_soc_services.sh)
- [`start_cti_component.sh`](../subcase_1c/scripts/start_cti_component.sh)
- [`fetch_cti_feed.sh`](../subcase_1c/scripts/fetch_cti_feed.sh)
- [`start_c2_server.sh`](../subcase_1c/scripts/start_c2_server.sh)
- [`benign_malware_simulator.ps1`](../subcase_1c/scripts/benign_malware_simulator.ps1)
- [`load_malware_simulation.ps1`](../subcase_1c/scripts/load_malware_simulation.ps1)

