#!/bin/bash

# Set the threshold for disk usage (in percentage)
IDSK_THRESHOLD=60

# Get the current disk usage
DISK_USEAGE=$(df /var/lib/docker/shared_cache | awk '{print $5}' | tail -1 | cut -d'%' -f1)

# Check if the disk usage is above the threshold
if [ "$DISK_USEAGE" -gt "$IDSK_THRESHOLD" ]; then
    # Find files that haven't been updated in the past 7 days
    FILES_TO_DELETE=$(find /var/lib/docker/shared_cache/* -mtime +7 -type f -exec dirname {} \; | sort -u)
    echo "The following files and folders will be deleted:"
    echo "$FILES_TO_DELETE"
    echo ""
    $FILES_TO_DELETE | xargs -r rm -r
    echo "$(date) - Cleaned up cache - Disk usage is now at $DISK_USEAGE%" >> /var/log/clean_cache.log
else
    echo "$(date) - No need to clean up cache - Disk usage is at $DISK_USEAGE%" >> /var/log/clean_cache.log
fi

# 0 2 * * * /path/to/gitlab_runner_cache_clean_script.sh: the script every day at 2am