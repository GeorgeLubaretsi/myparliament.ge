#!/bin/bash

# 

#  paths in FamilyIncome.xquery needs to be configured
 
saxon="/usr/local/bin/saxon9he.jar"


out="Parliament_familyincomeNoNames" ;  #"Parliament_familyincome";  #

outxml="$out.xml";
java -Xmx2G -cp  "$saxon" net.sf.saxon.Query  FamilyIncome.xquery    | xmllint --format - > $outxml
java -cp "$saxon" net.sf.saxon.Query  FamilyIncome2HTML.xquery doc="$outxml"  > "$out.html"
java -cp "$saxon" net.sf.saxon.Query  FamilyIncome2CSV.xquery  doc="$outxml"   > "$out.csv"
java -cp "$saxon" net.sf.saxon.Query  FamilyIncome2SQL.xquery doc="$outxml"   > "$out.sql"
 