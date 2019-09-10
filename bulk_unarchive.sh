#!/bin/sh
echo off
token=$(jq -r ".token" token.json)
export IFS=","
cat ML_Archived_Projects.csv | while read f1 f2 f3 f4
  do
    #discard first line based on the value of field 3 skill_id
    if [ $f1 != "project_id" ]; then
      curl -X PUT -H 'Authorization: Bearer '$token -H "Accept: Application/json" -H "Content-Type: application/json" "https://api.mavenlink.com/api/v1/workspaces/"$f1 -d '{ "workspace": {	"archived": false }}' >> $(date +%Y"-"%m"-"%d)_log.txt
    fi
  done
echo "Done: Please see " $(date +%Y"-"%m"-"%d)_log.txt "for detailed output."
