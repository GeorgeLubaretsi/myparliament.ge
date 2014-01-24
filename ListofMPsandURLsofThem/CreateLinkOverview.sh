#!/bin/sh

# Crawl the list of MP page, convert it into a list of names and links in both XML, CSV and JSON format

 #  paths   needs to be configured
saxon="/usr/local/bin/saxon9he.jar"
collectionpath="/Users/admin/Documents/TIGeorgia/DeclarationsScraper/Spreadsheets/xml/ka";  # path to Georgian Asset DEclaration collection
colpath_english='/Users/admin/Documents/TIGeorgia/DeclarationsScraper/Spreadsheets/xml/en'; # path to English Asset DEclaration collection

 
 # urls that may change....
AssetDeclarationURL="https://declaration.gov.ge/declaration/";  # Baseurl for asset declaration files: eg https://declaration.gov.ge/declaration/101
# the url we will scrape: page with links to pages of each MP at the parliament
url="http://parliament.ge/index.php?option=com_content&view=article&id=1682&Itemid=371&lang=ge"


../CrawlScripts/CleanGovPage.sh "$url"  # just downaloads that page and cleans it 



# don't touch what is below this line


outputtype='sql'  # sql|json depending on the type of output you want
out="MPlist-geo" ;  #"Parliament_familyincome";  #




java -Xmx1G -cp "$saxon" net.sf.saxon.Query CreateLinkOverview.xquery AssetDeclarationURL="$AssetDeclarationURL" colpath="$collectionpath" colpath_english="$colpath_english" outputtype="$outputtype"    > "$out.$outputtype"
 