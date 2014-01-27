#!/bin/sh

# Does all kind of updates for the representatives based on the Asset Declarations
#1) MPincome
#2) Properties, assets,family status and expenses
#3) urls/links to asset declarations, parliament page, and social media
#4) Total incomes and assets of the family members (old family income HTML table)


#  paths   that need  to be configured 
saxon="/usr/local/bin/saxon9he.jar"   # path the saxon
collectionpath="/Users/admin/Documents/TIGeorgia/DeclarationsScraper/Spreadsheets/xml/ka";  # path to Georgian Asset DEclaration collection
colpath_english='/Users/admin/Documents/TIGeorgia/DeclarationsScraper/Spreadsheets/xml/en'; # path to English Asset DEclaration collection

 
# don't touch what is below this line

# All SQL statements are written to "$out.$outputtype"   
outputtype='sql'  # sql|csv depending on the type of output you want
out="RepresentativeTableUpdate" ;   

 
 
 
 
 # MP income
java -Xmx1G -cp  "$saxon" net.sf.saxon.Query  MPincome.xquery  colpath="$collectionpath" colpath_english="$colpath_english" outputtype="$outputtype"   > "$out.$outputtype"   
# MP properties assets, family status and expenses
java -Xmx1G -cp  "$saxon" net.sf.saxon.Query MP_PropertiesAssets_Expenses_FamilyStatus.xquery colpath="$collectionpath" colpath_english="$colpath_english" outputtype="$outputtype"   >> "$out.$outputtype"   

#  MP urls  

# CONFIG urls that can change (if the site owners change them)....
AssetDeclarationURL="https://declaration.gov.ge/declaration/";  # Baseurl for asset declaration files: eg https://declaration.gov.ge/declaration/101
# the url we will scrape: page with links to pages of each MP at the parliament
url="http://parliament.ge/index.php?option=com_content&view=article&id=1682&Itemid=371&lang=ge"


../CrawlScripts/CleanGovPage.sh "$url"  # just downloads that page and cleans it 

 # scrapes Parliament page and Asset declarations header to create list of links
java -Xmx1G -cp "$saxon" net.sf.saxon.Query ../ListofMPsandURLsofThem/CreateLinkOverview.xquery AssetDeclarationURL="$AssetDeclarationURL" colpath="$collectionpath" colpath_english="$colpath_english" outputtype="$outputtype"    >> "$out.$outputtype"
 

#  the FamilyIncome table inserts
java -Xmx1G -cp  "$saxon" net.sf.saxon.Query  FamilyIncomeDBinserts.xquery  colpath="$collectionpath"  colpath_english="$colpath_english"     >> "$out.$outputtype"
   