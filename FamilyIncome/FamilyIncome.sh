#!/bin/bash

# Crawl the list of MP page, convert it into a list of names and links in both XML, CSV and JSON format

#  paths in FamilyIncome.xquery needs to be configured
 
saxon="/usr/local/bin/saxon9he.jar"


out="Parliament_familyincome";
outxml="$out.xml";
#java -cp "$saxon" net.sf.saxon.Query  FamilyIncome.xquery    | xmllint --format - > $outxml
java -cp "$saxon" net.sf.saxon.Query  FamilyIncome2HTML.xquery   > "$out.html"
java -cp "$saxon" net.sf.saxon.Query  FamilyIncome2CSV.xquery | sed '1d' > "$out.csv"
java -cp "$saxon" net.sf.saxon.Query  FamilyIncome2SQL.xquery | sed '1d' > "$out.sql"
 