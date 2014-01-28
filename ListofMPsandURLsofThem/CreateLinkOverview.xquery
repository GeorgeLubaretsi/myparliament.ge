(: Create a list of MP names and their URLs at parliament.ge from the page http://parliament.ge/index.php?option=com_content&view=article&id=1682&Itemid=371&lang=en
which is first downloaded and cleaned using CleanGovPage.sh	:)

declare namespace ti = "http://transparency.ge";

import module namespace tiUtil= "http://transparency.ge/XML-Utilities" at 
      "https://raw.github.com/tigeorgia/asset-declaration-scraper/master/scripts/XQueryTextMinerScripts/XMLUtilities.xquery"; 


declare option saxon:output "method=text";  (: output as text without xml header :)
declare option saxon:output    "omit-xml-declaration=yes";



declare variable $colpath external;  
declare variable $colpath_english external;   
declare variable $outputtype external;
declare variable $AssetDeclarationURL external ;  


(: debug 
declare variable $colpath :=  '/Users/admin/Documents/TIGeorgia/DeclarationsScraper/Spreadsheets/xml/ka' ;  
declare variable $colpath_english := '/Users/admin/Documents/TIGeorgia/DeclarationsScraper/Spreadsheets/xml/en' ;
declare variable $outputtype := 'sql';
declare variable $AssetDeclarationURL  := "https://declaration.gov.ge/declaration/" ;
:) 

declare variable $col := collection($colpath);
declare variable $eng_col := collection($colpath_english) ;

 

declare variable $baseurl := "http://parliament.ge/";




let $doc := doc('1682371.xml')  (: this is the document which is downloaded using 
    url="http://parliament.ge/index.php?option=com_content&view=article&id=1682&Itemid=371&lang=ge"
    ../CrawlScripts/CleanGovPage.sh "$url"
    :)

(: part for asset declarations :)
let $AD := $col[.//@name="ADheader"]
let $parlGEO := "საქართველოს პარლამენტი"
let $electiondate := "2012-10-01"
let $MPADs := $AD//tr[.//td[5][contains(.,$parlGEO)]]  (: only consider AD's whose organization equals "Parliament of Georgia" and who are filled after the election date :)                 
                 
                 (:   [.//td[7][. ge $electiondate]]  :)
(: end of part for Asset Declarations :)


(: let $AssetDeclaration := doc('/Users/admin/Documents/TIGeorgia/DeclarationsScraper/Spreadsheets/xml/ka/ADheader.xml')
:)

let $table := 
<table name='Parl_MPurls'>
{  
    let $contenttable:= $doc//*:table//*:table
   (:  let $head := $doc//*:p[normalize-space(.) ne ''][following::*:table]
    let $headstr := string-join($head,' ')
    order by $headstr
    :)
    return 
    for $row in $contenttable//*:tr[.//*:p]  (:only non empty rows:)  (: [position() ne 1]  :)
     let $MP:= normalize-space($row//*:td)
     let $MPclean := normalize-space(replace($MP,"\(.*\)",""))
     let $MPnames := tokenize($MPclean,' ')
     let $ADs := tiUtil:AssetDeclarations($MPnames[2],$MPnames[1],$MPADs) (: these are ordered inverse chronologically :) 
     let $lastAD := $ADs[1]
     let $LastADid := replace($lastAD//td[last()],'#','')   (: get the last asset declaration, and from that the ID :)
     let $NrofDaysneededForSubmittingAD := tiUtil:SubstractDates($electiondate,$lastAD//td[last() -1])
        return
            tiUtil:WriteSequenceAsTR( ("MPname","First name", "Last name", "Link at parliament.ge",
           (: "Last Asset Declaration",
           "Number of days  between electiondate and submission of Last Asset Declaration",
            "Total Number of Asset Declarations submitted",
            :)
            for $ad in $ADs return concat('Asset Declaration (',$ad//td[last() -1],')')
            ,
             
            "Wikipedia","Twitter","Facebook","LinkedIn"),
                                      ($MP,
                                      $MPnames[2],$MPnames[1],
                                      concat($baseurl,($row//*:td//*:a)[1]/@href),
                                     (: if ($LastADid = '') then '' else concat("https://declaration.gov.ge/declaration.php?id=",$LastADid),  
                                      string($NrofDaysneededForSubmittingAD),
                                      string(count($ADs)), :)
                                      for $ad in $ADs return concat($AssetDeclarationURL,replace($ad//td[last()],'#','')), (: all AD's :)
                                      concat("http://ka.wikipedia.org/w/index.php?search=",replace($MPclean,' ','%20')),
                                      concat("https://twitter.com/search?q=",replace($MPclean,' ','%20')),
                                      concat("http://www.facebook.com/search.php?q=",replace($MPclean,' ','%20')),
                                      concat("https://www.linkedin.com/vsearch/p?type=people&amp;keywords=",replace($MPclean,' ','%20'))
                                      ),
                                      'id'
            )
}
</table>


let $output :=

if ($outputtype='json') then tiUtil:trTOjson($table) else
if ($outputtype='csv') then tiUtil:trTOcsv($table) else
if ($outputtype='sql') then    

    for $row in $table//tr
    let $MPname := concat($row//td[2],' ',$row//td[3])
    let $MPinsertStat := concat("(SELECT person_id FROM popit_personname WHERE name_ka='",$MPname,"'",')')
    let $del := concat("&#10;DELETE FROM representative_url WHERE representative_id=",$MPinsertStat,'   AND (label LIKE "Asset%"  OR label LIKE "Link%" );')
    let $insert := for $url in $row//td
                   where starts-with($url/@id,'Link') or starts-with($url/@id,'Asset')
                   return 
                    concat("&#10;INSERT INTO representative_url (representative_id,label,url) VALUES (&#10;",
                           string-join(($MPinsertStat,tiUtil:QuotesAround($url/@id),tiUtil:QuotesAround($url/text())),',&#10;'),
                           ");"
                           )
     return ($del,$insert)
 else ''


 

 
return
  $output
(:
tiUtil:trTOcsv($absencetable)
:)