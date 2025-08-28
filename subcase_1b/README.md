# Subcase 1b Phishing Training

This scenario demonstrates a phishing training environment. A training platform sends simulated phishing emails to a trainee workstation, while the SOC server monitors related events using BIPS, NG-SIEM, NG-SOC, and CICMS.

## Usage

Run the startup scripts to generate sample phishing activity:

```bash
sudo subcase_1b/scripts/training_platform_start.sh
sudo subcase_1b/scripts/trainee_start.sh
```

Logs are written to `/var/log/training_platform/phishing.log` and `/var/mail/trainee` respectively.
