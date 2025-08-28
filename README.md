# TechAnalysisSecManage KYPO

This repository provides complete, ready‑to‑deploy instructions for two independent KYPO (CyberRangeCZ) scenarios using only the NG‑SOC components from the activity diagram: BIPS, NG‑SIEM, NG‑SOC, CICMS, CTEMS. It includes file layouts, Ansible roles, and step‑by‑step workflows so instructors and trainees can complete the training without confusion. One scenario delivers phishing‑awareness training with a policy briefing through the Random Education Platform, while the other models malware simulation and CTI integration. This repository contains materials for deploying and managing security analysis exercises on KYPO using this platform.

## Prerequisites

- Active account on [CyberRangeCZ](https://www.cyberrange.cz/) with permissions to deploy KYPO scenarios.
- SSH access to the range and ability to run privileged commands.
- Local tools: `git`, `kubectl`, `helm`, and a modern web browser.
- Recommended familiarity with NG-SOC components, including BIPS for behavioral intrusion prevention, NG-SIEM for event correlation, CICMS for incident collaboration, and CTEMS for CTI sharing and threat exposure management.

## Deployment on KYPO

1. **Clone the Repository**
   ```bash
   git clone https://github.com/example/techanalysissecmanage_kypo.git
   cd techanalysissecmanage_kypo
   ```
2. **Authenticate to CyberRangeCZ** – Ensure VPN or direct connectivity and log into the portal.
3. **Prepare the Scenario** – Upload required images or scripts (e.g., `subcase_1c/scripts/benign_malware_simulator.ps1`) to the appropriate KYPO repositories.
4. **Launch the Scenario** – Use the KYPO interface to create a new exercise and point it to this repository. Configure network ranges and participants as needed.
5. **Monitor the Exercise** – During execution, analysts should track alerts and manage cases using NG-SOC components such as BIPS, NG-SIEM, CICMS, and CTEMS (for CTI sharing), following the workflow described in [`docs/training_workflows.md`](docs/training_workflows.md).

## Teardown

1. Stop the scenario from the KYPO dashboard.
2. Remove any temporary resources or virtual machines associated with the exercise.
3. Archive logs and reports for after-action review.
4. Verify that no residual network configurations remain on CyberRangeCZ.

## Troubleshooting and Tool References

- **Connectivity Issues** – Confirm VPN status and that required ports (e.g., 22 for SSH) are open.
- **Scenario Fails to Start** – Ensure all prerequisite images are uploaded and that the repository path is correct.
- **Tool-Specific Logs** – Consult documentation for [BIPS](https://ngsoc.example.com/bips), [NG-SIEM](https://ngsoc.example.com/ng-siem), [CICMS](https://ngsoc.example.com/cicms), and [CTEMS](https://ngsoc.example.com/ctems).

Additional theoretical background and workflow guidance can be found in [`docs/training_workflows.md`](docs/training_workflows.md).

## Scenario Guides

- [Subcase 1b – Phishing-Awareness Training](docs/subcase_1b_guide.md)
Subcase 1b delivers phishing‑awareness training and a policy briefing via the Random Education Platform. It includes a trainee workstation and a SOC node running BIPS, NG‑SIEM, NG‑SOC, and CICMS, with detailed network assignments and startup scripts.
- [Subcase 1c – Malware Simulation and CTI Integration](docs/subcase_1c_guide.md)
Subcase 1c models a malware incident response exercise, adding a C2 server, a CTI component running CTEMS, and corresponding services for NG‑SIEM, BIPS, CICMS, and NG‑SOC. The roles download NG‑SOC packages with checksum verification, and the scripts launch services and simulations for training.
