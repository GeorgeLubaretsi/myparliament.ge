import module namespace FaminAD = "http://transparency.ge/AssetDeclarations/FamilyIncme" at "FamilyIncomeModule.xquery";
 
let  $ADheader :=   ($FaminAD:col[.//@name="ADheader"]//tr[contains(td[5],"საქართველოს პარლამენტი")])  (: Just parliamnet [contains(td[5],"საქართველოს პარლამენტი")]  :)  (: subsequence($col[.//@name="ADheader"]//tr,1,1)    [td[last()] = '#47806'] :)

let $ADrelatives := $FaminAD:col[.//@name="ADfamily_relations"]//tr

let $families := 
    for $row in $ADheader
        let $ADid := $row//td[last()]
        let $relatives := $ADrelatives[td[last()]=$ADid]
        
        return
        <AD id='{$ADid}' date='{$row//td[last()-1]}'>
        {
        FaminAD:RemoveDoubles(($row,$relatives)) (: remove members which have exactly the same name from the family, we always only keep the oldest :)
        }
        </AD>


 
return
 
 
 
 
 
 <root>{FaminAD:MakeFamilyIncome($families)}</root>
 
 
 (:
 (:
First we make the data using ti:MakeFamilyIncome($families) (that takes a long time), then we transform it into other formats with the 
     statements below (very fast) 
     :)
let $doc := doc('Parliament_familyincome.xml')
return
  (: ($SQLcreatetable,for $fam in $doc//div return  ti:WriteAsSQLInsert(ti:WriteAsNiceTable($fam))) :) (: for creating the SQL statements :)

for $fam in $doc//div return  ti:WriteAsNiceTable($fam)                  (: for creating the HTML view :)
(: for $fam in $doc//div return   tiUtil:trTOcsv(ti:WriteAsCSVTable($fam)) :)  (: for creating the csv :)
 
 

:)


