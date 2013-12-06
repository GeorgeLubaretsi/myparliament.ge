(: Create a list of MP names and their URLs at parliament.ge from the page http://parliament.ge/index.php?option=com_content&view=article&id=1682&Itemid=371&lang=en
which is first downloaded and cleaned using CleanGovPage.sh	:)


import module namespace tiUtil= "http://transparency.ge/XML-Utilities" at "/Users/admin/Documents/TIGeorgia/DeclarationsScraper/asset-declaration-scraper/scripts/XQueryTextMinerScripts/XMLUtilities.xquery";

(: declare variable $doc external;  :)



let $doc := doc('MPlist-geo.xml')
return
tiUtil:trTOcsv($doc)
 