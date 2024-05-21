#!/bin/bash

# Grab the date for naming the file
DATE=$(date --iso-8601=d)

# Copy the file into the Snoopy folder
sudo cp /var/lib/lxc/database/rootfs/var/log/auth.log ~/snoopy_logs/$DATE.log

# Clean the log file for new day
sudo lxc-attach -n database -- bash -c "cp /dev/null /var/log/auth.log"