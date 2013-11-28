
import module namespace tiUtil= "http://transparency.ge/XML-Utilities" at "/Users/admin/Documents/TIGeorgia/DeclarationsScraper/asset-declaration-scraper/scripts/XQueryTextMinerScripts/XMLUtilities.xquery";
 

declare variable $baseurl := "http://parliament.ge";

let $doc := doc('DraftlawOverview.xml')

let $table := 
<table>
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
                      tiUtil:pad(concat($baseurl,($p//a)[1]/@href))
                      )  (:reorder :)
order by $date descending
return
tiUtil:WriteSequenceAsTR($niceoutput)
}
</table>

return 
 

 tiUtil:trTOcsv($table)  