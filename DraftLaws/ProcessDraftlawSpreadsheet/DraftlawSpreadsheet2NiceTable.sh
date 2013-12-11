#!/bin/bash
# Script to turn the Intern spreadsheet of draftlaws into a nice looking HTML page

# process : 1) Download manually the **web view of the** ) spreadsheet  from "https://docs.google.com/spreadsheet/ar?id=tFdEiC_daNQz4LyIMtVYvGw.09950504104617165854.1324218163162093195&action=1&tile=3&rpert=20&srow=0&erow=282&scol=0&ecol=16&fprt=false&tfe=qg_891"
#(be sure to take the correct tab!!!)
# and save in $1 to this call

# Parameters:
# $1 : name of web verstion of the spreadsheet local
# $2 geo|eng (how the attributes will be written)
# $3 a url for the relative links. Use ''  if we keep the index and the draft overviews together

# writes to STDOUT

# Typical call $ ./DraftlawSpreadsheet2NiceTable.sh 2013-შემოდგომა.html geo '' > Draftlawoverview.html

saxon="/usr/local/bin/saxon9he.jar"


downloadedSpreadsheet=$1
lang=$2
url=$3
OurSpreadsheet="InternSpreadsheet.html"

cat $downloadedSpreadsheet |
grep -P  -o "<body .*</body>"  > "$OurSpreadsheet";

java -cp  "$saxon" net.sf.saxon.Query DraftlawSpreadsheet2NiceTable.xquery lang="$lang" doc="$OurSpreadsheet"  url="$url" |xmllint --format -
rm "$OurSpreadsheet"

