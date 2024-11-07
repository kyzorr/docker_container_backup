
# Docker Container Backup

A simple script to back up and restore Docker container volumes and configurations. Ideal for preserving data across container updates or migrations.

## Features

- **Backup**: Save Docker container data and configurations.
- **Restore**: Restore containers from backups easily.
- **Automated Workflow**: Schedule and automate backups for seamless data protection.

## Requirements

- Docker installed
- Permissions to run Docker commands

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/kyzorr/docker_container_backup.git
   cd docker_container_backup
   ```
2. Make scripts executable:
   ```bash
   chmod +x backup_script.sh restore_script.sh
   ```

## Usage

### Backup
Run the following to back up your container data:
   ```bash
   ./backup_script.sh <container_name> <backup_location>
   ```

### Restore
To restore a backup, use:
   ```bash
   ./restore_script.sh <backup_location> <container_name>
   ```

## Scheduling Backups

To schedule regular backups, use a cron job (Linux) or Task Scheduler (Windows).

Example cron job (daily at midnight):
   ```cron
   0 0 * * * /path/to/backup_script.sh my_container /path/to/backups/
   ```

## Contribution

Feel free to open issues or submit pull requests. Contributions to improve compatibility, efficiency, or add features are welcome.

## License

This project is open-source and available under the MIT License. See the [LICENSE](LICENSE) file for details.
