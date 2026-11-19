# Automated System Backup and Log Audit

## Aim
To create a Bash script that automates folder backup, checks file permissions, and rotates old log files.

## Requirements
- Linux terminal or Windows with WSL/Git Bash
- Bash
- `tar`, `find`, `date`, and standard Linux commands

## Files
- `scripts/backup_audit.sh` – main annotated Bash script
- `logs/` – output log folder (the script creates log files here)
- `backups/` – backup archive folder (the script creates backup files here)

## How to run
1. Open a Linux terminal in this project folder.
2. Give the script execute permission:
   ```bash
   chmod +x scripts/backup_audit.sh
   ```
3. Create a small test folder and a sample file:
   ```bash
   mkdir -p sample_data
   echo "Backup test file" > sample_data/example.txt
   ```
4. Run the script:
   ```bash
   ./scripts/backup_audit.sh sample_data
   ```
5. Check the generated files:
   ```bash
   ls -lh backups
   cat logs/backup_audit.log
   ```

## What the script does
1. Checks that the user supplied one source folder.
2. Checks that the folder exists.
3. Creates a compressed `.tar.gz` backup with a date and time in its name.
4. Searches for files that allow everyone to write to them and records warnings.
5. Removes rotated log copies older than seven days.
6. Saves a dated copy of the current log and records completion.

## Error handling
The script uses `set -Eeuo pipefail` and an error trap. It also checks for a missing argument and a source folder that does not exist. Errors are written to the log when possible.

## Example test cases
| Test | Command | Expected result |
|---|---|---|
| Valid folder | `./scripts/backup_audit.sh sample_data` | A `.tar.gz` backup and log are created |
| Missing argument | `./scripts/backup_audit.sh` | Usage instructions are displayed |
| Invalid folder | `./scripts/backup_audit.sh not_a_real_folder` | An error is recorded and the script exits |
| Permission audit | Create a test file with `chmod 666 sample_data/example.txt` and run again | A warning about world-writable permission is recorded |

## Important submission note
The activity asks for a GitHub repository link containing the annotated script and execution screenshots. This project folder is the source-code package. After running it in Linux, take genuine screenshots of the terminal output and upload the folder to a GitHub repository. Do not claim the script was executed until you have run it.
