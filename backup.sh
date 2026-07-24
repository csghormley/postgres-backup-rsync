#!/bin/bash
set -e

# Validate environment variables
if [ -z "$DATABASE_URL" ] || [ -z "$REMOTE_HOST" ] || [ -z "$REMOTE_USER" ] || [ -z "$REMOTE_PATH" ] || [ -z "$SSH_PRIVATE_KEY" ]; then
  echo "Missing required environment variables"
  echo "Required: DATABASE_URL, REMOTE_HOST, REMOTE_USER, REMOTE_PATH, SSH_PRIVATE_KEY"
  exit 1
fi

if [ -z "$SSH_PORT" ]; then
  SSH_PORT=22
fi

# Write SSH key to temp file
KEY_PATH="/tmp/backup_key"
echo "$SSH_PRIVATE_KEY" | base64 -d > "$KEY_PATH"
chmod 600 "$KEY_PATH"

TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
ENV_NAME=$(echo $RAILWAY_ENVIRONMENT_NAME | tr " " -)
BACKUP_FILE="/tmp/backup-${ENV_NAME}-${TIMESTAMP}.sql.gz"

trap "rm -f $KEY_PATH $BACKUP_FILE" EXIT

echo "Starting database backup..."

# Run pg_dump and compress
pg_dump "$DATABASE_URL" | gzip > "$BACKUP_FILE"

echo "Backup created: $BACKUP_FILE"
echo "Syncing to remote server..."

MAX_RETRIES=3
RETRY_DELAY=10
for attempt in $(seq 1 $MAX_RETRIES); do
  if rsync -avz -e "ssh -p$SSH_PORT -i $KEY_PATH -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
    "$BACKUP_FILE" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/"; then
    echo "Backup synced successfully"
    break
  fi
  if [ "$attempt" -lt "$MAX_RETRIES" ]; then
    echo "rsync failed (attempt $attempt/$MAX_RETRIES), retrying in ${RETRY_DELAY}s..."
    sleep "$RETRY_DELAY"
    RETRY_DELAY=$((RETRY_DELAY * 2))
  else
    echo "rsync failed after $MAX_RETRIES attempts"
    exit 1
  fi
done
