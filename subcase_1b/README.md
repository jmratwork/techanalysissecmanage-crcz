# Subcase 1b Penetration Testing Training

This scenario provides self-paced courses for penetration testing and vulnerability assessments. The Training Instructor uses the training platform to create new courses and configure Cyber Range scenarios that emulate CYNET's network infrastructure. Trainees execute semi-automated penetration test assessments to discover potential vulnerabilities and attack entry points.

## Usage

Run the startup scripts to deploy the exercise:

```bash
sudo subcase_1b/scripts/cyber_range_start.sh          # initialize Cyber Range
sudo subcase_1b/scripts/training_platform_start.sh     # set up course content
sudo subcase_1b/scripts/trainee_start.sh --target 10.10.0.4  # run sample scan
```

The training platform records course creation in `/var/log/training_platform/courses.log`. Trainee scan results are written to `/var/log/trainee/scans.log`, and the Cyber Range initialization log is at `/var/log/cyber_range/launch.log`.

## Virtualization

The cyber range is provisioned using Docker Compose. The `scripts/cyber_range_start.sh` helper launches or tears down the containerized environment:

```bash
sudo subcase_1b/scripts/cyber_range_start.sh       # start all containers
sudo subcase_1b/scripts/cyber_range_start.sh --down # stop and remove containers
```

The accompanying `docker-compose.yml` file defines services such as a vulnerable DVWA web server, a Kali-based workstation, and the training platform.

## Scenario Examples

`subcase_1b/scenario.yml` includes example exercises that can be used during courses:

- **dvwa_sql_injection** – explore SQL injection vulnerabilities in the DVWA service on port 8000.
- **weak_ssh_credentials** – practice brute-force attacks against weak SSH passwords on the trainee workstation.
