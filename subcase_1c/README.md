# Subcase 1c Malware Handling Training

## Objective
Design a comprehensive cyber security training plan focused on handling and mitigating malware attacks. This proactive approach involves theoretical and practical training on the utilization of automation techniques, tools and technologies, and incident response procedures to detect, contain, eradicate, and recover from malware attacks. Through this subcase, CYNET will improve its protection capabilities and capacities using state-of-the-art technology and solutions to better prepare, detect, and stop malware attacks. Furthermore, relevant intelligence (CTI) is shared with the appropriate audience (other entities and authorities) to enhance collective defense efforts and improve overall cybersecurity resilience.

Simulate benign malware activity and integrate threat intelligence feeds to exercise NG-SOC components.

## Node Roles
- **infected_host** – Windows victim that runs the benign malware simulator
- **c2_server** – Command-and-control server for beaconing traffic
- **soc_server** – Hosts NG-SOC platform services
- **cti_component** – Runs CTEMS and feeds threat intelligence to the SOC

## Required NG-SOC Components
- BIPS
- NG-SIEM
- NG-SOC
- CICMS
- CTEMS

## Execution Steps
1. **Start SOC services**
   ```bash
   sudo subcase_1c/scripts/start_soc_services.sh
   ```
2. **Start the CTI component**
   ```bash
   sudo subcase_1c/scripts/start_cti_component.sh
   ```
3. **Launch the C2 server**
   ```bash
   sudo subcase_1c/scripts/start_c2_server.sh
   ```
4. **Run the Windows malware simulator**
   ```powershell
   $env:BEACON_URL = "http://localhost:5601/beacon"  # optional override
   .\subcase_1c\scripts\benign_malware_simulator.ps1 -BeaconCount 3
   ```

For deeper guidance and troubleshooting tips, see [the Subcase 1c guide](../docs/subcase_1c_guide.md).
