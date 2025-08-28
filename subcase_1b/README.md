# Subcase 1b Phishing Identification Training

This scenario delivers a phishing‑email identification exercise with an accompanying policy briefing. The Random Education Platform (REP) sends simulated messages to a trainee workstation, and SOC analysts follow the BIPS → NG‑SIEM → NG‑SOC → CICMS chain to track related events.

## Usage

Run the startup scripts to deploy the exercise:

```bash
sudo subcase_1b/scripts/soc_server_start.sh      # BIPS, NG-SIEM, NG-SOC, CICMS
sudo subcase_1b/scripts/training_platform_start.sh  # Random Education Platform
sudo subcase_1b/scripts/trainee_start.sh         # Trainee workstation
```

Trainees log into REP to classify emails and review policy notes. Logs are written to `/var/log/training_platform/phishing.log` and `/var/mail/trainee` respectively.
