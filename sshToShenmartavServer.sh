#!/bin/bash

pathToScripts=$PWD/FamilyIncome
host=****
user=****
pathToScriptsOnRemoteServer=/home/tigeorgia/shenmartav/sqlscripts

scp $pathToScripts/MPincome.sql $user@$host:$pathToScriptsOnRemoteServer/MPincome.sql

ssh $user@$host 'bash -s' < $pathToScripts/runSqlFile.sh
