(: Create a list of MP names and their URLs at parliament.ge from the page http://parliament.ge/index.php?option=com_content&view=article&id=1682&Itemid=371&lang=en
which is first downloaded and cleaned using CleanGovPage.sh	:)


import module namespace tiUtil= "http://transparency.ge/XML-Utilities" at "/Users/admin/Documents/TIGeorgia/DeclarationsScraper/asset-declaration-scraper/scripts/XQueryTextMinerScripts/XMLUtilities.xquery";

(: declare variable $doc external;  :)

declare variable $baseurl := "http://parliament.ge/";

let $doc := doc('1682371.xml')


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
     
        return
            tiUtil:WriteSequenceAsTR( ("MPname","First name", "Last name", "Link at parliament.ge","Wikipedia","Twitter","Facebook","LinkedIn"),
                                      ($MP,
                                      $MPnames[2],$MPnames[1],
                                      concat($baseurl,$row//*:td//*:a/@href),
                                      concat("http://ka.wikipedia.org/w/index.php?search=",replace($MPclean,' ','%20')),
                                      concat("https://twitter.com/search?q=",replace($MPclean,' ','%20')),
                                      concat("http://www.facebook.com/search.php?q=",replace($MPclean,' ','%20')),
                                      concat("https://www.linkedin.com/vsearch/p?type=people&amp;keywords=",replace($MPclean,' ','%20'))
                                      ),
                                      'id'
            )
}
</table>
return
 $table
(:
tiUtil:trTOcsv($absencetable)
:)