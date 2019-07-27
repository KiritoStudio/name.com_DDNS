#!/bin/bash -e
# Please fill domainName, userName, token, host to script first

merlin_router_ip=
update_DDNS ()
{
    domainName=""
    userName=""
    token=""
    host=""
    json=$(curl -u "$userName:$token" "https://api.name.com/v4/domains/$domainName/records")
    update_id=$(echo $json | jq '.records | .[] | select(.host == "h" and .type == "A") | .id')
    echo $update_id
    data="{\"host\":\"$host\",\"type\":\"A\",\"answer\":\"$ip\",\"ttl\":300}"
    echo $data
    if [ -z $update_id ]
    then
        echo "add new record"
        curl -u "$userName:$token" "https://api.name.com/v4/domains/$domainName/records" -X POST --data $data
    else
        echo "update by id:${update_id}"
        curl -u "$userName:$token" "https://api.name.com/v4/domains/$domainName/records/$update_id" -X PUT --data $data
    fi
    echo $ip > ipcache.txt
}

if [ -e ipcache.txt ]
then
    echo "has cache"
    cache=$(cat ipcache.txt)
else
    echo "no cache"
    cache=""
fi
ip=$(ssh admin@$merlin_router_ip "ifconfig ppp0" | ggrep -oP "(?<=inet addr:)[0-9]{1,3}[\.].[0-9]{1,3}[\.].[0-9]{1,3}[\.].[0-9]{1,3}(?=.*)")
if [ "$ip" != "$cache" ]
then
    update_DDNS
else 
    echo "no need update"
fi