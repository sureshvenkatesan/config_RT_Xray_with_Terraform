#!/bin/bash
# Export all repo configurations to  /tmp/all_repos.txt
#https://stackoverflow.com/questions/65692591/bash-loop-a-curl-request-output-to-file-and-stop-until-empty-response




ART_ROOT="$PROTOCOL://$MYSERVERHOST_IP/artifactory/api"
for REPO in $(curl -s -S -X GET "${ART_ROOT}/repositories" | grep "key" | awk '{print $3}' | sed 's/\"//g' | sed 's/,//g')
do
    #check if the repo  has a PUSH replication defined
   data=$(curl -u "${MYUSER}:${MYPASSWORD}" -s   -X GET "${ART_ROOT}/repositories/${REPO}")
   [[    $data ]] || break
       echo "$data ,"   >> /tmp/all_repos.txt

done