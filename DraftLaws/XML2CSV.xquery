
(: convert a table XML to a CSV file :)

import module namespace tiUtil= "http://transparency.ge/XML-Utilities" at "/Users/admin/Documents/TIGeorgia/DeclarationsScraper/asset-declaration-scraper/scripts/XQueryTextMinerScripts/XMLUtilities.xquery";
 
 

declare variable $xml external; (: name of xml file to convert to csv :)
   
 tiUtil:trTOcsv(doc($xml))   