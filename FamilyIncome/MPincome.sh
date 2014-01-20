#!/bin/sh

# 

#  paths   needs to be configured
 
# The import module statement in  MPincome.xquery
saxon="/usr/local/bin/saxon9he.jar"
collectionpath="/Users/admin/Documents/TIGeorgia/DeclarationsScraper/Spreadsheets/xml/ka";  # path to Georgian Asset DEclaration collection
colpath_english='/Users/admin/Documents/TIGeorgia/DeclarationsScraper/Spreadsheets/xml/en'; # path to English Asset DEclaration collection

 
# don't touch what is below this line


outputtype='sql'  # sql|csv depending on the type of output you want
out="MPincome" ;  #"Parliament_familyincome";  #

 
java -Xmx1G -cp  "$saxon" net.sf.saxon.Query  MPincome.xquery  colpath="$collectionpath" colpath_english="$colpath_english" outputtype="$outputtype"   > "$out.$outputtype"   
 