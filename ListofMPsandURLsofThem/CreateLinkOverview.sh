#!/bin/bash

# Crawl the list of MP page, convert it into a list of names and links in both XML, CSV and JSON format

# this path needs to be configured
adheader="/Users/admin/Documents/TIGeorgia/DeclarationsScraper/Spreadsheets/xml/ka/ADheader_ka.xml";

url="http://parliament.ge/index.php?option=com_content&view=article&id=1682&Itemid=371&lang=ge"

../CrawlScripts/CleanGovPage.sh "$url"

java -cp /usr/local/bin/saxon9he.jar net.sf.saxon.Query CreateLinkOverview.xquery  GeoAssetDeclaration="$adheader" | xmllint --format - > MPlist-geo.xml
java -cp /usr/local/bin/saxon9he.jar net.sf.saxon.Query CreateLinkOverviewAsJSON.xquery | sed '1d' > MPlist-geo.json
java -cp /usr/local/bin/saxon9he.jar net.sf.saxon.Query CreateLinkOverviewAsCSV.xquery | sed '1d' > MPlist-geo.csv
