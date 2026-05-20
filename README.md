# Postgres Backup Service

Automated daily backup of Postgres database via rsync to a remote server.

## Setup

1. Create a GitHub repo and push these files
2. Connect the repo to Railway
3. Set environment variables:
   - `DATABASE_URL` — from your Postgres service
   - `REMOTE_HOST` — backup server hostname
   - `REMOTE_USER` — SSH user on backup server
   - `REMOTE_PATH` — directory path on backup server (e.g., `/backups`)
   - `SSH_PRIVATE_KEY` — base64-encoded SSH private key

## Encoding SSH Key

```bash
cat ~/.ssh/id_rsa | base64 -w 0
