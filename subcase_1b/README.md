# Subcase 1b Vulnerable Web App

The `web_vuln_start.sh` script installs the [Damn Vulnerable Web Application (DVWA)](https://github.com/digininja/DVWA) from an internal repository and launches it for trainees.

## Usage

```bash
sudo subcase_1b/scripts/web_vuln_start.sh
```

The script downloads DVWA to `/var/www/dvwa`, creates `/usr/local/bin/run_dvwa.sh`, and starts the application on port `8080`. Logs are written to `/var/log/web_vuln/dvwa.log`.

## Credentials and Setup

1. Browse to `http://<vm-ip>:8080/setup.php` and click **Create/Reset Database**.
2. Use the default database credentials:
   - Username: `dvwa`
   - Password: `p@ssw0rd`
3. Log into DVWA with:
   - Username: `admin`
   - Password: `password`

Adjust the `WEB_PORT` or `DVWA_REPO` environment variables if needed before running the start script.
