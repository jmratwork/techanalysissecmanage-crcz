# Subcase 1b Guide: Phishing Training

## Objective
Simulate a phishing campaign and analyze trainee responses using NG-SOC monitoring components.

## Tasks

1. **Start SOC services**
   ```bash
   sudo subcase_1b/scripts/soc_server_start.sh
   ```
   Launches BIPS, NG-SIEM, CICMS, and NG-SOC.

2. **Launch the training platform**
   ```bash
   sudo subcase_1b/scripts/training_platform_start.sh
   ```
   Sends simulated phishing emails to the trainee.

3. **Run the trainee simulation**
   ```bash
   sudo subcase_1b/scripts/trainee_start.sh
   ```
   Logs receipt of the phishing email.

4. **Monitor with NG-SOC tools**
   Use BIPS for intrusion prevention alerts, NG-SIEM for event correlation, CICMS for case tracking, and NG-SOC for dashboard visibility.

## Expected Outcomes

- Phishing log written to `/var/log/training_platform/phishing.log`.
- Trainee mailbox updated at `/var/mail/trainee`.
- BIPS (5500), NG-SIEM (5601), CICMS (5800), and NG-SOC (5900) running.

## References

- [`training_platform_start.sh`](../subcase_1b/scripts/training_platform_start.sh)
- [`trainee_start.sh`](../subcase_1b/scripts/trainee_start.sh)
- [`soc_server_start.sh`](../subcase_1b/scripts/soc_server_start.sh)
