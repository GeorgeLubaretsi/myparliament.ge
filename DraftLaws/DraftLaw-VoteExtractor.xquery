
import module namespace tiUtil= "http://transparency.ge/XML-Utilities" at "/Users/admin/Documents/TIGeorgia/DeclarationsScraper/asset-declaration-scraper/scripts/XQueryTextMinerScripts/XMLUtilities.xquery";
 

declare variable $baseurl := "http://parliament.ge";
declare variable $col := collection('VotingRecordsRaw');

declare variable $AnalysisType external; (: vote|outcome :)

 
let $VotesPerLaw := 
<table>
{
for $doc in $col

let $draftlawID := replace(string(replace(document-uri($doc),'.*/','')),'\..*','')


for $p in $doc//*:tr[.//*:tc[.//*:t] ]
 let    $output := $p//*:tc[.//*:t]  
 let $output := (reverse(tiUtil:ParseStringToFirstNameLastName($output[1])),subsequence($output,2,10))
 
 order by $draftlawID
return
tiUtil:WriteSequenceAsTR(($draftlawID,$output))
}
</table>


let $OutcomePerLaw := 
<table>
{
for $doc in $col

let $draftlawID := replace(string(replace(document-uri($doc),'.*/','')),'\..*','')

let $outcome :=     for $t in $doc//*:tbl/following::*:p[.//*:t]//*:t[ not (matches(.,'^ *$'))] return normalize-space($t)
let $outcome := tokenize(replace(replace(string-join($outcome,''),' +',''),'(\d+)',':$1;'),' ')  
let $niceroutcome := tokenize($outcome,';')
(: we choose to output as attributes instead of as td elements. :)
let $supernice:= <tr><td>{
                    (
                    attribute {"LawID"} {$draftlawID}
                    ,
                    for $av in $niceroutcome 
                    let $pair := tokenize($av,':')
                    return
                    attribute {$pair[1]} {$pair[2]}
                    )
                    }
                    </td></tr>
  order by $draftlawID
  return 
   (: tiUtil:WriteSequenceAsTR(($draftlawID,$supernice)) :) $supernice
 }
 </table>
 
 return
 
 if ($AnalysisType='vote') then $VotesPerLaw else
 if ($AnalysisType='outcome') then $OutcomePerLaw else
 "ERROR: unknown outcome type. Should be one of vote|outcome"
  
(: or $VotesPerLaw, or if you want CSV:  tiUtil:trTOcsv($VotesPerLaw)  :)