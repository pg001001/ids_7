#!/bin/bash

# Check if domain is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

# Function to scan for JavaScript files, download them, and search for sensitive information
sensitive_scan() {
    local domain=$1
    local base_dir="${domain}"
    mkdir -p "${base_dir}"
    mkdir -p "${base_dir}/exposure/"

    dirsearch -u "${domain}" -r -w '/root/main/wordlist/cgi-bin.txt' -o "${base_dir}/exposure/cgi-bin.txt"
    dirsearch -u "${domain}" -r -w '/root/main/wordlist/cgi-files.txt' -o "${base_dir}/exposure/cgi-files.txt"
    dirsearch -u "${domain}" -r -w '/root/main/wordlist/config.txt' -o "${base_dir}/exposure/config.txt"
    dirsearch -u "${domain}" -r -w '/root/main/wordlist/ec2.txt' -o "${base_dir}/exposure/ec2.txt"
    dirsearch -u "${domain}" -r -w '/root/main/wordlist/env.txt' -o "${base_dir}/exposure/env.txt"
    dirsearch -u "${domain}" -r -w '/root/main/wordlist/git_config.txt' -o "${base_dir}/exposure/git_config.txt"
    dirsearch -u "${domain}" -r -w '/root/main/wordlist/keys.txt' -o "${base_dir}/exposure/keys.txt"
    dirsearch -u "${domain}" -r -w '/root/main/wordlist/leaky-misconfigs.txt' -o "${base_dir}/exposure/leaky-misconfigs.txt"
    dirsearch -u "${domain}" -r -w '/root/main/wordlist/log.txt' -o "${base_dir}/exposure/log.txt"

}

# Run the JS scan function with the provided domain
sensitive_scan "$1"
