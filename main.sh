#!/bin/bash

# Check if domain is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

domain=$1

# Ensure all required scripts are executable
chmod +x subdomain_find.sh url_find.sh information.sh port_scan.sh sensitive_file_find.sh 

# Run subdomain enumeration 
echo "Starting subdomain enumeration..."
./subdomain_find.sh "$domain"

# Run URL enumeration 
echo "Starting url enumeration..."
./url_find.sh "$domain"

# Run JavaScript file analysis 
echo "Starting JavaScript file analysis..."
./information.sh "$domain"

# Run port scanning 
# echo "Starting port scanning..."
./port_scan.sh "$domain"

echo "All tasks completed for ${domain}. Results are stored in the respective directories."
