#!/bin/sh

# run this script on the machine storing the backups

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# delete all but the last n backups
KEEP=12
PREFIXES="production staging"

echo "Starting cleanup"
echo ""

for PRE in $PREFIXES; do
    
    FILESPEC=$SCRIPT_DIR/backup-$PRE-*sql.gz
    FILE_CT=$(ls -1 $FILESPEC | wc -l)
    
    echo "Searching $FILESPEC..."
    echo "  $PRE: $FILE_CT/$KEEP backup files found"
    echo ""

    # delete the oldest files exceeding KEEP
    ls -t $FILESPEC 2>/dev/null | tail -n +$KEEP | xargs rm -f

done
