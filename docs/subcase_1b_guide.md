# Subcase 1b Guide: Phishing Training

## Objective
Provide phishing‑email identification training with an accompanying policy briefing. Trainees practice spotting malicious messages inside the Random Education Platform (REP) while SOC analysts monitor activity through NG‑SOC components.

## Deployment Steps

1. **Start SOC services**
   ```bash
   sudo subcase_1b/scripts/soc_server_start.sh
   ```
   Launches BIPS, NG-SIEM, CICMS, and NG-SOC.

2. **Launch the Random Education Platform (REP)**
   ```bash
   sudo subcase_1b/scripts/training_platform_start.sh
   ```
   Sends simulated phishing emails for trainees to classify and review against the policy briefing.

3. **Run the trainee simulation**
   ```bash
   sudo subcase_1b/scripts/trainee_start.sh
   ```
   Logs receipt of the phishing email.

4. **Monitor with NG-SOC tools**
   SOC analysts follow the BIPS → NG‑SIEM → NG‑SOC → CICMS chain to view alerts, correlate events, and open cases.

## Expected Outcomes

- REP writes a phishing log to `/var/log/training_platform/phishing.log`.
- Trainee mailbox updated at `/var/mail/trainee`.
- BIPS (5500), NG-SIEM (5601), CICMS (5800), and NG-SOC (5900) running.

## References

- [`training_platform_start.sh`](../subcase_1b/scripts/training_platform_start.sh)
- [`trainee_start.sh`](../subcase_1b/scripts/trainee_start.sh)
- [`soc_server_start.sh`](../subcase_1b/scripts/soc_server_start.sh)
