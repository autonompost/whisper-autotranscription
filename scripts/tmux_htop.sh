#!/bin/bash
set -x

# Read the IP addresses from the file and store them in an array
mapfile -t ips < <(awk '/^[0-9]/ { print $1 }' ../ansible/hosts.cfg)

# Start a new tmux session
tmux new-session -d -s htop

# Loop through each IP address and create a new tmux window
for ip in "${ips[@]}"; do
    tmux new-window -t htop -n "$ip" "ssh -i ../id_rsa root@$ip TERM=xterm && htop"
done

# Attach to the new tmux session
tmux attach-session -t htop

