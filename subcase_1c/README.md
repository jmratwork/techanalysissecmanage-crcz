# Subcase 1c Malware Handling Training

## Objective
Design a comprehensive cyber security training plan focused on handling and mitigating malware attacks. This proactive approach involves theoretical and practical training on the utilization of automation techniques, tools and technologies, and incident response procedures to detect, contain, eradicate, and recover from malware attacks. Through this subcase, CYNET will improve its protection capabilities and capacities using state-of-the-art technology and solutions to better prepare, detect, and stop malware attacks. Furthermore, relevant intelligence (CTI) is shared with the appropriate audience (other entities and authorities) to enhance collective defense efforts and improve overall cybersecurity resilience.

Simulate benign malware activity and integrate threat intelligence feeds to exercise NG-SOC components.

## Node Roles
- **infected_host** – Windows victim that runs the benign malware simulator
- **c2_server** – Command-and-control server for beaconing traffic
- **soc_server** – Hosts NG-SOC platform services
- **cti_component** – Runs MISP and feeds threat intelligence to the SOC

## Required NG-SOC Components
- BIPS
- NG-SIEM
- NG-SOC
- CICMS
- MISP

For a cross-reference of tools, versions, and documentation, see the [NG-SOC components matrix](../docs/ngsoc_components_matrix.md).

## Workflow
1. **Service initialization** – The instructor provisions the exercise inside the RandomSec LMS and launches NG-SOC services with [scripts/start_soc_services.sh](scripts/start_soc_services.sh).
2. **CTI ingestion** – The trainee activates the CTI component using [scripts/start_cti_component.sh](scripts/start_cti_component.sh) so threat intelligence flows into the SOC.
3. **SOC analysis** – Acting as a SOC analyst, the trainee investigates alerts produced by [scripts/start_c2_server.sh](scripts/start_c2_server.sh) and [scripts/benign_malware_simulator.ps1](scripts/benign_malware_simulator.ps1), documenting findings in the platform.
4. **Automated mitigation** – NG-SIEM and BIPS forward events to the Decide service, which recommends responses consumed by the Act orchestrator.
5. **Instructor feedback** – Results and lessons learned are submitted back through the RandomSec LMS where instructors review the analysis and provide guidance.

## Execution Steps
> **Note:** The startup scripts in this subcase expect `systemctl`. If systemd is unavailable, run them with `DIRECT_START=1` in the environment to use fallback `service` or direct commands.
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

5. **Query mitigation recommendations**
   ```bash
   curl -X POST http://localhost:8000/recommend \
        -H 'Content-Type: application/json' \
        -d '{"source":"ng-siem","severity":5}'
   ```

For deeper guidance and troubleshooting tips, see [the Subcase 1c guide](../docs/subcase_1c_guide.md).
