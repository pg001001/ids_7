#!/bin/bash

# Function to find subdomains for a given domain
find_subdomains() {
    local domain=$1
    local date=$(date +'%Y-%m-%d')
    local base_dir="${domain}/$([ "$IGNORE_SPLIT" = "false" ] && echo "${date}/")"
    mkdir -p "${base_dir}"
    
    # Subdomain enumeration
    
    # subfinder
    echo "Running Subfinder for ${domain}..."
    subfinder -d "${domain}" -all -recursive -o "${base_dir}/subfinder.txt"
    
    
    # sublist3r
    #echo "Running Sublist3r for ${domain}..."
    # sublist3r2 -d "${domain}" -v -o "${base_dir}/sublist3r.txt"
    
    # amass
    echo "Running Amass for ${domain}..."
    amass intel -whois -d "${domain}" -o "${base_dir}/amass-intel.txt"
    
    # crst subdomain
    echo "Running Crst for ${domain}..."
    crtsh -d "${domain}" | tee "${base_dir}/crst.txt"
    
    # findomain subdomain
    echo "Running findomain for ${domain}..."
    findomain -t "${domain}" | tee -a "${base_dir}/findomain.txt"
    
    # assetfinder subdomain
    echo "Running assetfinder for ${domain}..."
    assetfinder "${domain}" | tee -a "${base_dir}/assetfinder.txt"

    # echo "Running gobuster for subdomain brute force on ${domain}..."
    # gobuster dns -d "${domain}" -w "/root/main/subdomains_brute_force/subdomains_tiny.txt" -o "${base_dir}/dns_brute_force.txt" --wildcard
    # sed 's/Found: //g' "${base_dir}/dns_brute_force.txt" | tee -a  "${base_dir}/brute_force.txt"
    # rm -r "${base_dir}/dns_brute_force.txt"
    
    # Combine all results into one file, sort and make unique
    echo "Combining all subdomain results..."
    # cat "${base_dir}"/*.txt | sort -u > "${base_dir}/all_subdomains.txt"
    find "${base_dir}" -name "*.txt" -exec cat {} + | sort -u | grep -i "${domain}" | tee "${base_dir}/subdomains.txt"

    # Check for live domains using httprobe or httpx
    echo "Checking for live domains..."
    if command -v httprobe &> /dev/null; then
        cat "${base_dir}/subdomains.txt" | httprobe > "${base_dir}/live_subdomains.txt"
    elif command -v httpx &> /dev/null; then
        cat "${base_dir}/subdomains.txt" | httpx -silent -o "${base_dir}/live_subdomains.txt"
    else
        echo "Neither httprobe nor httpx is installed. Please install one of them to check for live domains."
    fi
}

# Check if domain is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

# Run the subdomain finder function with the provided domain
find_subdomains "$1"
