 
import module namespace tiUtil= "http://transparency.ge/XML-Utilities" at "/Users/admin/Documents/TIGeorgia/DeclarationsScraper/asset-declaration-scraper/scripts/XQueryTextMinerScripts/XMLUtilities.xquery";
 

let $doc := doc('CommitteeAbsence.xml')
  return
  tiUtil:trTOcsv($doc)