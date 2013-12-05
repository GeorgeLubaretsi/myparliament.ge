import module namespace tiUtil= "http://transparency.ge/XML-Utilities" at "/Users/admin/Documents/TIGeorgia/DeclarationsScraper/asset-declaration-scraper/scripts/XQueryTextMinerScripts/XMLUtilities.xquery";

let $col := collection('/Users/admin/Documents/TIGeorgia/Parliament/CommitteeAbsence/RawAbsenceCommittees')

let $absencetable := 
<table name="Parl_CommitteeAbsence">
{ for $doc in $col
    let $head := $doc//*:p[normalize-space(.) ne ''][following::*:table]
    let $headstr := string-join($head,' ')
    order by $headstr
    return
    for $row in $head/following::*:table//*:tr[position() ne 1]
    let $name := reverse(tiUtil:ParseStringToFirstNameLastName($row//*:td[3]))
    (: Tricky because they write dates as 19.02.13 instead of 19.02.2013   :)
   let $dates := string-join( for $date in  $row//*:td[4]//*:p[. ne ''] return 
                  tiUtil:toISOdate(
                    replace(
                        replace($date,';','')
                        ,'(.*)\.(.*)','$1.20$2'
                    )
                  )
                  ,
                  ';') 
                   
                  
                  
     
        return
            tiUtil:WriteSequenceAsTR(($name, $row//*:td[2],$dates,$headstr))
}
</table>
return
$absencetable
(:
tiUtil:trTOcsv($absencetable)
:)