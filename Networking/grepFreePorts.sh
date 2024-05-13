#!/bin/bash

# Function to extract valid host names from SSH config that start with 'sw-'
get_hostnames_from_ssh_config() {
    local valid_hostname_regex='^[a-zA-Z0-9.-]+$'
    grep '^Host sw-' /root/.ssh/config | awk '{print $2}' | grep -E "$valid_hostname_regex"
}


perform_ssh() {
    local host=$1
    local pass=$2

    echo -e "\n---- Results from $host ----"
    echo "----------------------------------------"
    sshpass -p "$pass" ssh -o StrictHostKeyChecking=no "$host" "sh int status | include notconnect"
}


read -s -p "Enter password for SSH: " ssh_password
echo ""

# Read hostnames into an array
mapfile -t hosts < <(get_hostnames_from_ssh_config)

select_host() {
    echo "Please select the number for the host:"
    select host in "${hosts[@]}"; do
        if [[ -n $host && $REPLY =~ ^[0-9]+$ && $REPLY -le ${#hosts[@]} ]]; then
            echo "Selected host: $host"
            break
        else
            echo "Invalid selection, try again."
        fi
    done
    return 0 
}


echo "Select the number for the first host:"
select_host
host_1=$host


echo "Select the number for the second host:"
select_host
host_2=$host

if [[ -z "$ssh_password" || -z "$host_1" || -z "$host_2" ]]; then
    echo "Error: Password and hostnames must not be empty."
    exit 1
fi

perform_ssh "$host_1" "$ssh_password"
echo -e "\n==================================================\n"
perform_ssh "$host_2" "$ssh_password"
echo -e "\n==================================================\n"

:'
                __  
   ____ _____ _/ /_ 
  / __ `/ __ `/ __ \        13/05/2024
 / /_/ / /_/ / /_/ /        gab@propel.sh
 \__, /\__,_/_.___/ 
/____/              
'