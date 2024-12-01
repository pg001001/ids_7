#!/bin/bash

# Function to perform port scanning for a given domain
port_scan() {
    local domain=$1
    local date=$(date +'%Y-%m-%d')
    local base_dir="${domain}/$([ "$IGNORE_SPLIT" = "false" ] && echo "${date}/")"
    mkdir -p "${base_dir}"
    
    # Port scanning using naabu
    echo "Running naabu for ${domain}..."
    naabu -host "${domain}" -top-ports 100 -nmap-cli 'nmap -sV -oX nmap-output' | tee -a "${base_dir}/ports.txt"
    mv nmap-output "${base_dir}"
}

# Check if domain is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

# Run the port scan function with the provided domain
port_scan "$1"