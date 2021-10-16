#!/bin/bash

function prepareFolders() {
    rm -rf retrieve/*
    rm -rf orgs/*
    
    for org in "$@"
    do
      mkdir -p retrieve/$org
      mkdir -p orgs/$org
    done
}

function retrieveMetadata() {
  i=1

  for f in ./packages/*.xml; do
      for org in "$@"
      do
        sfdx force:mdapi:retrieve -u "$org" -k "$f" --singlepackage --retrievetargetdir "./retrieve/$org/$i" & 
      done
      
      let "i += 1"
  done
  wait
  
  unzipPackages "$@"
}


function unzipPackages() {
      i=1
    
      for f in ./packages/*.xml; do
          for org in "$@"
          do
              unzip -o -qq "./retrieve/$org/$i/unpackaged.zip" -d "./orgs/$org/"
          done
          
          let "i += 1"
      done
      wait
}

function queryData() {
    i=1

    for f in ./queries/*.soql; do
        SOQL="$(cat $f | tr -s '\n' ' ')"
        fileName="$(basename -- $f)"
        
        for org in "$@"
        do
            mkdir -p "./orgs/$org/data"
            sfdx force:data:soql:query -u "$org" -q "$SOQL" -r csv $([[ $fileName =~ .*__t.soql$ ]] && echo "--usetoolingapi") > "./orgs/$org/data/$fileName.csv" &
        done
        
        let "i += 1"
    done
    
    wait
}

function createComparisonRepository() {
    initRepository
    commitSandboxes "$@"
}

function initRepository() {
    if [ -d "./orgs/gitcompare" ]
    then
        (
            cd ./orgs/gitcompare || exit
            git reset --hard ROOT
        )
    else 
        mkdir ./orgs/gitcompare

        (
            cd ./orgs/gitcompare || exit
            git init
            git commit --allow-empty -m 'init'
            git tag -a -m '' ROOT
        )
    fi
}

function commitSandboxes() {
  for org in "$@"
  do
    rm -r ./orgs/gitcompare/*
    cp -a "./orgs/$org/." "./orgs/gitcompare/"
    
    (
        cd ./orgs/gitcompare || exit
        git add --all
        git commit --quiet -m "$org"
    )
  done
}

