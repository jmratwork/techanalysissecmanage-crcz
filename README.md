# TechAnalysisSecManage KYPO

This repository provides complete, ready‑to‑deploy instructions for double KYPO (CyberRangeCZ) scenarios using only the NG‑SOC components from the activity diagram: BIPS, NG‑SIEM, NG‑SOC, CICMS, etc. It includes file layouts, Ansible roles, and step‑by‑step workflows so instructors and trainees can complete the training without confusion. One scenario delivers penetration testing and vulnerability assessment training through a dedicated platform and Cyber Range simulation, while the other models malware simulation and CTI integration. This repository contains materials for deploying and managing security analysis exercises on KYPO using this platform.

## Prerequisites

- Active account on [CyberRangeCZ](https://www.cyberrange.cz/) with permissions to deploy KYPO scenarios.
- SSH access to the range and ability to run privileged commands.
- Local tools: `git`, `kubectl`, `helm`, and a modern web browser.
- Recommended familiarity with NG-SOC components, including BIPS for behavioral intrusion prevention, NG-SIEM for event correlation, CICMS for incident collaboration, and MISP for CTI sharing.
- The provided startup scripts rely on `systemctl`. If your environment lacks systemd, set `DIRECT_START=1` to attempt starting services with legacy `service` commands or direct scripts.
- Prepare required environment variables such as `LTI_TOOL_PRIVATE_KEY`, `MISP_API_KEY`, and `OPENEDX_URL` as described in [docs/env_variables.md](docs/env_variables.md).

## Deployment on KYPO

See [deployment manual](docs/deployment_manual.md) for detailed steps including VM preparation, service orchestration, teardown, and environment reset.


1. **Clone the Repository**
   ```bash
   git clone https://github.com/example/techanalysissecmanage_kypo.git
   cd techanalysissecmanage_kypo
   ```
2. **Authenticate to CyberRangeCZ** – Ensure VPN or direct connectivity and log into the portal.
3. **Prepare the Scenario** – Upload required images or scripts (e.g., `subcase_1c/scripts/benign_malware_simulator.ps1`) to the appropriate KYPO repositories.
4. **Launch the Scenario** – Use the KYPO interface to create a new exercise and point it to this repository. Configure network ranges and participants as needed.
5. **Monitor the Exercise** – During execution, analysts should track alerts and manage cases using NG-SOC components such as BIPS, NG-SIEM, CICMS, and MISP (for CTI sharing), following the workflow described in [`docs/training_workflows.md`](docs/training_workflows.md) and the deployment/validation steps in [`docs/subcase_1c_guide.md`](docs/subcase_1c_guide.md).

### Phishing Quiz Module

Running `subcase_1b/scripts/training_platform_start.sh` launches a training platform that now includes a phishing-awareness quiz. Set the `PASSWORD` environment variable to a strong value before starting the service. Once the service is up, the following endpoints can be used to interact with the quiz:

- `GET /quiz/start` – obtain questions.
- `POST /quiz/submit` – send answers and record the score.
- `GET /quiz/score` – retrieve stored scores per user and course.

See [`docs/subcase_1b_guide.md`](docs/subcase_1b_guide.md) for detailed examples.

### Tool Launch Endpoint

The training platform also provides a `POST /launch_tool` route to run
predefined **Nmap**, **ZAP**, or **Caldera** operations against the KYPO
subnet. Supply the authentication `token` and desired `tool` in the JSON
body to start a job. The response returns a `job_id` and initial
`status`. Poll `GET /launch_tool/<job_id>?token=...` to obtain the latest
status and command output, allowing the UI to show progress or completion
to the trainee.

### Importing Open edX Content

Sample lessons and a quiz are provided under `open_edx/course`. To load this material into Open edX Studio:

1. Archive the directory:
   ```bash
   zip -r phishing_course.zip open_edx/course
   ```
2. In Studio, open the target course and navigate to **Tools → Import**.
3. Upload `phishing_course.zip` to add the lessons and quiz.

## Teardown

1. Stop the scenario from the KYPO dashboard.
2. Remove any temporary resources or virtual machines associated with the exercise.
3. Archive logs and reports for after-action review.
4. Verify that no residual network configurations remain on CyberRangeCZ.

## Troubleshooting and Tool References

- **Connectivity Issues** – Confirm VPN status and that required ports (e.g., 22 for SSH) are open.
- **Scenario Fails to Start** – Ensure all prerequisite images are uploaded and that the repository path is correct.
- **Tool-Specific Logs** – Consult documentation for [BIPS](https://ngsoc.example.com/bips), [NG-SIEM](https://ngsoc.example.com/ng-siem), [CICMS](https://ngsoc.example.com/cicms), and [MISP](https://ngsoc.example.com/misp).

Additional theoretical background and workflow guidance can be found in [`docs/training_workflows.md`](docs/training_workflows.md). For day‑to‑day alert handling, analysts should review the [`SOC Analyst Playbook`](docs/soc_analyst_playbook.md).

## Scenario Guides

![Pilot CYNET](PUC%20-%20CYNET.png)

- [Subcase 1b – Penetration Testing Training](docs/subcase_1b_guide.md)
Subcase 1b delivers self-paced penetration testing and vulnerability assessment training using a dedicated training platform, a trainee workstation, and a Cyber Range simulation of CYNET's network.
- [Subcase 1c – Malware Simulation and CTI Integration](docs/subcase_1c_guide.md)
Subcase 1c models a malware incident response exercise, adding a C2 server, a CTI component running MISP, and corresponding services for NG‑SIEM, BIPS, CICMS, and NG‑SOC. The guide covers deployment, attack simulation, validation, and configuration of detection rules and playbooks.

## KYPO Training Packaging

After adding or modifying sandbox definitions, you can validate and publish the training module using the `kypo` CLI:

1. **Validate** the training specification:
   ```bash
   kypo training validate training.yaml
   ```
2. **Pack** the training for distribution:
   ```bash
   kypo training pack training.yaml
   ```
3. **Publish** the package to a KYPO portal:
   ```bash
   kypo training publish training.yaml
   ```
   The publish command expects authentication details appropriate for your KYPO instance.
