#!/bin/bash

# Function to perform URL enumeration for a given domain
url_enumeration() {
    local domain=$1
    local date=$(date +'%Y-%m-%d')
    local base_dir="${domain}/$([ "$IGNORE_SPLIT" = "false" ] && echo "${date}/")"
    mkdir -p "${base_dir}"
    
    # gau
    echo "Running gau for ${domain}..."
    gau "${domain}" --subs --blacklist png,jpg,gif,jpeg,swf,woff,svg | tee -a "${base_dir}/allurls.txt" > /dev/null

    # katana
    echo "Running katana for ${domain}..."
    echo "${domain}" | katana -jc -silent >> "${base_dir}/js.txt"

    # waymore
    # echo "Running waymore for ${domain}..."
    waymore -i "${domain}" -mode U -c "${HOME}/config.yml" -oU "${base_dir}/allurls.txt"
    
    # Remove duplicate URLs
    # echo "Removing duplicate URLs..."
    sort -u "${base_dir}/allurls.txt" -o "${base_dir}/allurls.txt"

    # echo "Getting live urls for ${domain}..."
    cat "${base_dir}/allurls.txt" | httpx -random-agent -retries 2 -mc 200,403,500 -o "${base_dir}/liveallurls.txt" 2>/dev/null
    # halive "${base_dir}/allurls.txt" -o "${base_dir}/liveallurls.txt" 2>/dev/null
    
    mkdir -p "${base_dir}/vuln/"
    
    #find endpoints for specific attacks
    tests=(
        "idor"
        "img-traversal"
        "interestingEXT"
        "interestingparams"
        "interestingsubs"
        "lfi"
        "rce"
        "redirect"
        "sqli"
        "ssrf"
        "ssti"
        "xss"
    )
    
    # Loop through each test variable and execute the command
    for test in "${tests[@]}"; do
        echo "Running gf for $test..."
        # Output the result to a file named after the test in the specified vuln subdirectory
        cat "${base_dir}/liveallurls.txt" | gf $test > "${base_dir}/vuln/$test.txt"
    done

    # paramspider --domain "${domain}" --exclude woff,css,js,png,svg,php,jpg --output "${base_dir}/paramspider_${domain}.txt"
}

# Check if domain is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

# Run the URL enumeration function with the provided domain
url_enumeration "$1"
