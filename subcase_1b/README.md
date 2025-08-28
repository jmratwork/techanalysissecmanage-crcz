# Subcase 1b Vulnerable Web App

The `web_vuln_start.sh` script installs the [Damn Vulnerable Web Application (DVWA)](https://github.com/digininja/DVWA) from a configurable source and launches it for trainees. The application can be cloned from a Git repository or extracted from a prepackaged archive bundled with the scenario for offline use.

## Usage

```bash
sudo subcase_1b/scripts/web_vuln_start.sh
```

The script places DVWA in `/var/www/dvwa`, creates `/usr/local/bin/run_dvwa.sh`, and starts the application on port `8080`. Logs are written to `/var/log/web_vuln/dvwa.log`.

### Configuration

Environment variables or Ansible inventory values can be used to configure deployment:

- `WEB_PORT` – Port for the built-in PHP server (default `8080`).
- `DVWA_REPO` – Git URL to clone DVWA from.
- `DVWA_ARCHIVE` – Path to a prepacked DVWA `tar.gz` archive. If not provided, the script looks for `subcase_1b/dvwa.tar.gz`.

If both `DVWA_ARCHIVE` and `DVWA_REPO` are supplied, the archive takes precedence.

## Credentials and Setup

1. Browse to `http://<vm-ip>:8080/setup.php` and click **Create/Reset Database**.
2. Use the default database credentials:
   - Username: `dvwa`
   - Password: `p@ssw0rd`
3. Log into DVWA with:
   - Username: `admin`
   - Password: `password`

For offline deployments place a `dvwa.tar.gz` archive alongside the scenario or specify `DVWA_ARCHIVE` to its location. To clone from a repository, set `DVWA_REPO` via an environment variable or by defining `dvwa_repo`/`dvwa_archive` in the Ansible inventory for the `web_vuln` host.
