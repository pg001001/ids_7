#!/bin/bash

# Check if domain is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

# Function to scan for JavaScript files, download them, and search for sensitive information
scan_information() {
    local domain=$1
    local base_dir="${domain}"
    mkdir -p "${base_dir}"
    mkdir -p "${base_dir}/information/"

    # sensitive information in downloaded JavaScript files
    mkdir -p "${base_dir}/js_files/"  && xargs -a "${base_dir}/js.txt" -I {} wget -q {} -P "${base_dir}/js_files/"
    # katana -mdc "contains(endpoint,"api")" -jc -u ${domain} >> "${base_dir}/information/api_endpoints.txt"
    cat "${base_dir}/allurls.txt" | grep "\.js$"  "${base_dir}/allurls.txt" | httpx -mc 200 | tee "${base_dir}/js.txt"
    grep -r --color=always -i -E "api_key|apikey|aws" "${base_dir}/js_files/" | tee "${base_dir}/information/js.txt"
    
    # emails
    grep -r --color=always -i -E "@" "${base_dir}/allurls.txt" >> "${base_dir}/information/emails.txt"
    grep -r --color=always -i -E "%40" "${base_dir}/allurls.txt" >> "${base_dir}/information/emails.txt"
    grep -r --color=always -i -E "gmail|yahoo|hotmail|outlook" "${base_dir}/allurls.txt" >> "${base_dir}/information/common_emails.txt"

    # Encoded credentials and emails
    grep -r --color=always -i -E "==|\.com:|@" "${base_dir}/allurls.txt" >> "${base_dir}/information/encoded_creds_emails.txt"

    # billngs
    grep -r --color=always -i -E "invoice|billing|payment|receipt|bill|purchase|order|checkout|transaction" "${base_dir}/allurls.txt" >> "${base_dir}/information/pay.txt"

    # credentials
    grep -r --color=always -i -E "register:|signin:|signup:|login:" "${base_dir}/allurls.txt" >> "${base_dir}/information/credentials.txt"

    # search sensitive files 
    grep -r --color=always -i -E "\.pdf" "${base_dir}/allurls.txt" >> "${base_dir}/information/pdfs_file.txt"
    grep -r --color=always -i -E ".\xlsx|\.doc|\.docx|\.pptx|\.xls" "${base_dir}/allurls.txt" >> "${base_dir}/information/documents.txt"
    
    # Admin panels and related paths
    grep -r --color=always -i -E "admin" "${base_dir}/subdomains.txt" >> "${base_dir}/information/admin_panels.txt"
    grep -r --color=always -i -E "admin|login|signin|dashboard" "${base_dir}/subdomains.txt" >> "${base_dir}/information/admin_panels.txt"

    # get parameters 
    gau -subs ${domain} | grep -oP "(\?|\&)\w+" | tr -d "?|&" | sort -u | tee params.txt
    gau -subs ${domain} | grep -oP "(\?|\&)\w+" | tr -d "?|&" | sort -u | tee "${base_dir}/information/params.txt"


    # Backup files (.zip, .7z, .exe, .tar, .gz, .dll, .iso)
    grep -r --color=always -i -E "\.zip|\.7z|\.exe|\.tar|\.gz|\.dll|\.iso" "${base_dir}/allurls.txt" >> "${base_dir}/information/backup_files.txt"
    grep -r --color=always -i -E "\.zip|\.tgz|\.bak|\.7z|\.rar\.zip|\.exe|\.tar|\.gz|\.dll|\.iso" "${base_dir}/allurls.txt" >> "${base_dir}/information/backup.txt"

    # Tokens, API Keys, reset password
    grep -r --color=always -i -E "token=|apikey=|/resetpassword/" "${base_dir}/allurls.txt" >> "${base_dir}/information/tokens_keys.txt"

    # Sensitive parameters (code=, etc.)
    grep -r --color=always -i -E "code=|\.aspx|\.ashx|\.php|\.jsp|\.cgi|\.xml|\.txt|\.xhtml" "${base_dir}/allurls.txt" >> "${base_dir}/information/sensitive_params.txt"

}

scan_information "$1"
