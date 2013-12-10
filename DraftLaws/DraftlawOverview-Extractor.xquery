
import module namespace tiUtil= "http://transparency.ge/XML-Utilities" at "/Users/admin/Documents/TIGeorgia/DeclarationsScraper/asset-declaration-scraper/scripts/XQueryTextMinerScripts/XMLUtilities.xquery";
 

declare variable $baseurl := "http://parliament.ge";

declare variable $lawsearchurl := "https://matsne.gov.ge/index.php?searchQuery=&amp;searchTarget=title&amp;searchDocumentsFilter=main&amp;documentTypeGroup=&amp;issuer=&amp;issuer2=&amp;documentNumber=REPLACE_ME&amp;issueDateS=&amp;issueDateE=&amp;registrationNumber=&amp;publishDateS=&amp;publishDateE=&amp;documentStatus=&amp;documentAdditionalStatus=&amp;courtDecisionsCOURT=&amp;courtDecisionsCATEGORY=&amp;courtDecisionsARGUMENT=&amp;agreementSide=&amp;sortCombo=signingDate_desc&amp;queryString=&amp;option=com_ldmssearch&amp;sortField=&amp;sortDirection=&amp;view=docSearchResults&amp;searchType=advanced&amp;limitstart=0";

let $doc := doc('DraftlawOverview.xml')




let $table := 
<table date='{current-dateTime()}'>
{
for $p in $doc//p[.//a] 
let $text :=   string-join($p//text()[string-length(.) gt 1],' ')  (: text we want :)
let $rawdate := replace($text,'.*[^\d](\d?\d *\. *\d?\d *\. *\d\d\d\d).*','$1')
let $text := replace($text,$rawdate,'')  (: text without the date :) 
 
let $LawNR := replace(replace(replace($text,'.*[^\d](\d+.*)$','$1'),' ',''),',$','')
  
let $date := tiUtil:toISOdate(replace($rawdate,' ',''))  (: turn date into iso format  (first delete all spaces) :)
let $niceoutput := (  tiUtil:pad($date), 
                      tiUtil:pad($LawNR),
                      tiUtil:pad(tiUtil:NoDoubleQuotes(replace($text,',$',''))),
                      tiUtil:pad(concat($baseurl,($p//a)[1]/@href)),
                      tiUtil:pad(replace($lawsearchurl,'REPLACE_ME',$LawNR))
                      )  (:reorder :)
order by $date descending
return
tiUtil:WriteSequenceAsTR($niceoutput)
}
</table>

return 
 $table

 (: tiUtil:trTOcsv($table)  :)