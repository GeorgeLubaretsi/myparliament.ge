#!/bin/sh

# 

#  paths   needs to be configured
 
saxon="/usr/local/bin/saxon9he.jar"
collectionpath="/Users/admin/Documents/TIGeorgia/DeclarationsScraper/Spreadsheets/xml/ka";  # path to Georgian Asset DEclaration collection

# don't touch what is below this line


outputtype='sql'  # sql|csv depending on the type of output you want
out="MPincome" ;  #"Parliament_familyincome";  #

 
java -Xmx1G -cp  "$saxon" net.sf.saxon.Query  MPIncome.xquery  colpath="$collectionpath"  outputtype="$outputtype"   > "$out.$outputtype"  #| sort|uniq|sed '/^$/d'
 