# TechAnalysisSecManage KYPO

This repository contains materials for deploying and managing security analysis exercises on CyberRangeCZ using the KYPO platform.

## Prerequisites

- Active account on [CyberRangeCZ](https://www.cyberrange.cz/) with permissions to deploy KYPO scenarios.
- SSH access to the range and ability to run privileged commands.
- Local tools: `git`, `kubectl`, `helm`, and a modern web browser.
- Recommended familiarity with NG-SOC tools such as Wazuh, Suricata, Zeek, TheHive, and Kibana.

## Deployment on CyberRangeCZ

1. **Clone the Repository**
   ```bash
   git clone https://github.com/example/techanalysissecmanage_kypo.git
   cd techanalysissecmanage_kypo
   ```
2. **Authenticate to CyberRangeCZ** – Ensure VPN or direct connectivity and log into the portal.
3. **Prepare the Scenario** – Upload required images or scripts (e.g., `benign_malware_simulator.ps1`) to the appropriate KYPO repositories.
4. **Launch the Scenario** – Use the KYPO interface to create a new exercise and point it to this repository. Configure network ranges and participants as needed.
5. **Monitor the Exercise** – During execution, analysts should observe alerts in NG-SOC tools and guide trainees through the workflow described in [`docs/training_workflows.md`](docs/training_workflows.md).

## Teardown

1. Stop the scenario from the KYPO dashboard.
2. Remove any temporary resources or virtual machines associated with the exercise.
3. Archive logs and reports for after-action review.
4. Verify that no residual network configurations remain on CyberRangeCZ.

## Troubleshooting and Tool References

- **Connectivity Issues** – Confirm VPN status and that required ports (e.g., 22 for SSH) are open.
- **Scenario Fails to Start** – Ensure all prerequisite images are uploaded and that the repository path is correct.
- **Tool-Specific Logs** – Consult documentation for [Wazuh](https://documentation.wazuh.com/), [Suricata](https://suricata.readthedocs.io/), [Zeek](https://docs.zeek.org/), [TheHive](https://docs.thehive-project.org/), and [Kibana](https://www.elastic.co/guide/en/kibana/current/index.html).

Additional theoretical background and workflow guidance can be found in [`docs/training_workflows.md`](docs/training_workflows.md).
