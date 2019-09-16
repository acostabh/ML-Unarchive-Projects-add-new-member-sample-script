#!/bin/sh
echo off
token=$(jq -r ".token" token.json)
max_pages=200 #maximum number of results per page (200 is the limit set by Mavenlink)
archived=$(curl -H 'Authorization: Bearer '$token 'https://api.mavenlink.com/api/v1/workspaces?archived=only&per_page='$max_pages'&page=1')
count=$(jq -n "$archived" | jq -r '.count')
page_count=$(jq -n "$archived" | jq -r '.meta.page_count')

if [ $count == 0 ]; then
  echo "No Archived Projects found!"
else
  if [ $1 == "w" ]; then
    echo ""
    echo "Writing file: ML_Archived_Projects.CSV"
    #write CSV header
    echo "project_id,project_name,user_id,role" > ML_Archived_Projects.csv
    #if number of pages > than 1, iterate through
    for (( i=1; i < $((page_count+1)); ++i ))
      do
        if [ $i != 1 ]; then
          archived=$(curl -H 'Authorization: Bearer '$token 'https://api.mavenlink.com/api/v1/workspaces?archived=only&per_page='$max_pages'&page='$i)
          count=$(jq -n "$archived" | jq -r '.count')
        fi
        #iterate the users list per page
        for (( j=0; j < $count; ++j ))
          do
            id=$(jq -n "$archived" | jq -r '.results['$j'].id')
            if [ $id != null ]; then
              #append CSV user data by line
              echo $id',"'$(jq -n "$archived" | jq -r '.workspaces["'$id'"].title')'"' >> ML_Archived_Projects.csv
            fi
          done #end users list iteration
        done #ends page iteration
      echo ""
      echo "Done!"
    else
      echo ""
      echo "######################## User List ######################"
      echo "This is a sample view only list to write it out to a CSV,"
      echo "run the script with the w switch: ./get_projects.sh w"
      echo "#########################################################"
      echo ""
      for (( i=0; i < $count; ++i ))
        do
          id=$(jq -n "$archived" | jq -r '.results['$i'].id')
          if [ $id != null ]; then
            echo "[" $id "] "$(jq -n "$archived" | jq -r '.workspaces["'$id'"].title')
          fi
        done
    fi
  echo ""
fi
