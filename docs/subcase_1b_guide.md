# Subcase 1b Guide: Vulnerable Web App

## Objective
Deploy a vulnerable web application and analyze attacker activity using NG-SOC monitoring components.

## Tasks

1. **Start SOC services**  
   ```bash
   sudo subcase_1b/scripts/soc_server_start.sh
   ```  
   Launches BIPS, NG-SIEM, CICMS, and NG-SOC.

2. **Deploy the web application**  
   ```bash
   sudo subcase_1b/scripts/web_vuln_start.sh
   ```  
   Installs and runs DVWA on port 8080.

3. **Run the attacker simulation**  
   ```bash
   sudo subcase_1b/scripts/attacker_start.sh
   ```  
   Generates network reconnaissance against the target.

4. **Monitor with NG-SOC tools**  
   Use BIPS for intrusion prevention alerts, NG-SIEM for event correlation, CICMS for case tracking, and NG-SOC for dashboard visibility.

## Expected Outcomes

- DVWA reachable at `http://<vm-ip>:8080` with default credentials.
- BIPS (5500), NG-SIEM (5601), CICMS (5800), and NG-SOC (5900) running.
- Attacker activity recorded in NG-SIEM and BIPS, with cases optionally opened in CICMS.

## References

- [`web_vuln_start.sh`](../subcase_1b/scripts/web_vuln_start.sh)
- [`attacker_start.sh`](../subcase_1b/scripts/attacker_start.sh)
- [`soc_server_start.sh`](../subcase_1b/scripts/soc_server_start.sh)

