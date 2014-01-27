#!/bin/bash

# create insert statements on family income

#  paths   that need  to be configured 
saxon="/usr/local/bin/saxon9he.jar"   # path the saxon
collectionpath="/Users/admin/Documents/TIGeorgia/DeclarationsScraper/Spreadsheets/xml/ka";  # path to Georgian Asset DEclaration collection
colpath_english='/Users/admin/Documents/TIGeorgia/DeclarationsScraper/Spreadsheets/xml/en'; # path to English Asset DEclaration collection

 
# don't touch what is below this line

# All SQL statements are written to "$out.$outputtype"   

outputtype='sql'  # sql|csv depending on the type of output you want


out="Parliament_familyincome" ;  #"Parliament_familyincome";  #


java -Xmx1G -cp  "$saxon" net.sf.saxon.Query  FamilyIncomeDBinserts.xquery  colpath="$collectionpath"  colpath_english="$colpath_english"     >> "$out.$outputtype"


#Old way of doing things
#java -Xmx2G -cp  "$saxon" net.sf.saxon.Query  FamilyIncome.xquery    | xmllint --format - > $outxml
#java -cp "$saxon" net.sf.saxon.Query  FamilyIncome2HTML.xquery doc="$outxml"  > "$out.html"
#java -cp "$saxon" net.sf.saxon.Query  FamilyIncome2CSV.xquery  doc="$outxml"   > "$out.csv"
#java -cp "$saxon" net.sf.saxon.Query  FamilyIncome2SQL.xquery doc="$outxml"   > "$out.sql"
 