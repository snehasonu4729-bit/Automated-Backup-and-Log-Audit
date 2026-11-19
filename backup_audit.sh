#!/usr/bin/env bash
# Automated System Backup and Log Audit
# Backs up a selected folder, checks file permissions, and rotates old log files.

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="${PROJECT_DIR}/logs"
BACKUP_DIR="${PROJECT_DIR}/backups"
LOG_FILE="${LOG_DIR}/backup_audit.log"
RETENTION_DAYS=7

mkdir -p "$LOG_DIR" "$BACKUP_DIR"

log_message() {
    local message="$1"
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$message" | tee -a "$LOG_FILE"
}

show_usage() {
    echo "Usage: $0 <source_directory>"
    echo "Example: $0 \"$HOME/Documents/sample-folder\""
}

handle_error() {
    local exit_code=$?
    log_message "ERROR: Script stopped near line ${BASH_LINENO[0]} (exit code ${exit_code})."
    exit "$exit_code"
}
trap handle_error ERR

if [[ $# -ne 1 ]]; then
    show_usage
    exit 1
fi

SOURCE_DIR="$1"

if [[ ! -d "$SOURCE_DIR" ]]; then
    log_message "ERROR: Source directory does not exist: $SOURCE_DIR"
    exit 1
fi

SOURCE_DIR="$(cd -- "$SOURCE_DIR" && pwd)"
TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"
BACKUP_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.tar.gz"

log_message "Backup process started."
log_message "Source directory: $SOURCE_DIR"

# Create a compressed archive of the selected source folder.
SOURCE_PARENT="$(dirname -- "$SOURCE_DIR")"
SOURCE_NAME="$(basename -- "$SOURCE_DIR")"
tar -czf "$BACKUP_FILE" -C "$SOURCE_PARENT" "$SOURCE_NAME"
log_message "Backup created: $BACKUP_FILE"

# Audit files that are writable by everyone (permission bit 0002).
log_message "Starting permission audit."
AUDIT_COUNT=0
while IFS= read -r -d '' file; do
    log_message "WARNING: Other users have write permission: $file"
    AUDIT_COUNT=$((AUDIT_COUNT + 1))
done < <(find "$SOURCE_DIR" -type f -perm -0002 -print0)

if [[ "$AUDIT_COUNT" -eq 0 ]]; then
    log_message "Permission audit completed: no world-writable files found."
else
    log_message "Permission audit completed: $AUDIT_COUNT world-writable file(s) found."
fi

# Rotate the script log by removing dated rotated logs older than retention period.
log_message "Starting log rotation (retention: ${RETENTION_DAYS} days)."
find "$LOG_DIR" -maxdepth 1 -type f -name 'backup_audit.log.*' -mtime +"$RETENTION_DAYS" -print -delete \
    | while IFS= read -r old_log; do
        log_message "Removed old log: $old_log"
      done

# Keep the current log and make a dated copy for the next run.
cp "$LOG_FILE" "${LOG_FILE}.${TIMESTAMP}"
log_message "Log rotation completed."
log_message "Backup and audit process completed successfully."
echo "Completed. Backup: $BACKUP_FILE"
echo "Log: $LOG_FILE"
