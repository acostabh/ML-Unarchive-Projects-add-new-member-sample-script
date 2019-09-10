#!/bin/sh
echo off
token=$(jq -r ".token" token.json)
export IFS=","
cat ML_Archived_Projects.csv | while read f1 f2 f3 f4
  do
    #discard first line based on the value of field 3 skill_id
    if [ $f1 != "project_id" ]; then
      #iterate through the list of user IDs in field 3 (user ID)
      IFS=/
      id=($f3)
      for key in "${!id[@]}"; do
        user_id=${id[$key]}
        curl -X POST -H 'Authorization: Bearer '$token -H "Accept: Application/json" -H "Content-Type: application/json" "https://api.mavenlink.com/api/v1/participations" -d '{ "participation": {	"workspace_id": '$f1', "role": "maven", "user_id": '$user_id' }}' >> $(date +%Y"-"%m"-"%d)_log.txt
      done
      #reset IFS to split string based on a comma to iterate the next CSV line.
      export IFS=","
    fi
  done
echo "Done: Please see " $(date +%Y"-"%m"-"%d)_log.txt "for detailed output."
