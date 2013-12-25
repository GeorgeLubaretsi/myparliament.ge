import module namespace FaminAD = "http://transparency.ge/AssetDeclarations/FamilyIncme" at "FamilyIncomeModule.xquery";
 
 import module namespace tiUtil= "http://transparency.ge/XML-Utilities" at "/Users/admin/Documents/TIGeorgia/DeclarationsScraper/asset-declaration-scraper/scripts/XQueryTextMinerScripts/XMLUtilities.xquery";
declare namespace ti = "http://transparency.ge";
declare namespace xsd="http://www.w3.org/2001/XMLSchema";


(: putting this out, Chrome does not display it well :)
(: declare option saxon:output "omit-xml-declaration=yes"; :)
(: declare option saxon:output "method=html"; :)  (: output as text without xml header :)
 
declare variable $doc external;  
   


 (:
First we make the data using ti:MakeFamilyIncome($families) (that takes a long time), then we transform it into other formats with the 
     statements below (very fast) 
     :)
let $doc := doc($doc)
return
  (:  ($SQLcreatetable,for $fam in $doc//div return  ti:WriteAsSQLInsert(ti:WriteAsNiceTable($fam))) :)(: for creating the SQL statements :)

 for $fam in $doc//div return  FaminAD:WriteAsNiceTable($fam)                  (: for creating the HTML view :)
(:  for $fam in $doc//div return   tiUtil:trTOcsv(ti:WriteAsCSVTable($fam))  :) (: for creating the csv :)
 
 




