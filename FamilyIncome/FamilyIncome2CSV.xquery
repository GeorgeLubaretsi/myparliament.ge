
(:  


A fantastic example is https://declaration.gov.ge/eng/declaration?id=48161
 
 
 TODO: 
 
 * shell script for on git
 * Somthing still goes wrong with the entrepeneurial activities
 *  

GEORGIAN VERSION
:)

declare namespace ti = "http://transparency.ge";
declare namespace xsd="http://www.w3.org/2001/XMLSchema";

import module namespace tiUtil= "http://transparency.ge/XML-Utilities" at "/Users/admin/Documents/TIGeorgia/DeclarationsScraper/asset-declaration-scraper/scripts/XQueryTextMinerScripts/XMLUtilities.xquery";
 
declare variable $USD_GELexchange_rate  := number(1.65); (: see http://www.xe.com/currencycharts/?from=USD&to=GEL&view=5Y , we guessed the average in the period 2010-2013 :)
declare variable $language := "geo"; (: eng|geo :) 
declare variable $public_official := if ($language = 'eng') then 'Public Official' else 'საჯარო თანამდებობის პირის';
declare variable $ADbaseurl := "https://declaration.gov.ge/declaration?id=";
declare variable $ADbaseurlENG := "https://declaration.gov.ge/eng/declaration?id=";
declare variable  $English_Ent_Activity := doc('/Users/admin/Documents/TIGeorgia/DeclarationsScraper/Spreadsheets/xml/en/ADentrepreneurial_activity_en.xml');


declare variable $col := collection('/Users/admin/Documents/TIGeorgia/DeclarationsScraper/Spreadsheets/xml/ka') ;
declare variable $eng_col := collection('/Users/admin/Documents/TIGeorgia/DeclarationsScraper/Spreadsheets/xml/en') ;
 
declare function ti:WriteAsNiceTable($family){
(: delete names when we delete the names again :)
<table class='family_income' border='1' >
{
($family/@*,
<tr>
 <th>First Name</th><th>Last Name</th> 
<th>Family Role</th><th>Gender</th><th>Age</th><th>% Household Income</th><th>Income</th><th></th><th>Car</th></tr>,
<caption>Income of the household of {string($family/@po)} declared at {string($family/@date)} (<a href="{concat($ADbaseurl,replace($family/@id,"#",''))}">Source (geo)</a>) 
(<a href="{concat($ADbaseurlENG,replace($family/@id,"#",''))}">Source (eng)</a>).</caption>,
$family//tr
)
}
</table>
};

declare function ti:WriteAsCSVTable($family){
<table>
{
for $tr in $family//tr return
    <tr><td>{$family/@id}</td>{$tr//td}</tr>
}
</table>

};

declare variable $SQLcreatetable := "
-- Table: representative_url

-- DROP TABLE representative_family_income;

CREATE TABLE representative_family_income
(
  id serial NOT NULL,
  representative_id integer,
  ad_id integer,
  html_table text NOT NULL,
  CONSTRAINT representative_family_income_pkey PRIMARY KEY (id),
  CONSTRAINT representative_id_refs_person_ptr_id FOREIGN KEY (representative_id)
      REFERENCES representative_representative (person_ptr_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED
)
WITH (
  OIDS=FALSE
);
ALTER TABLE representative_family_income
  OWNER TO shenmartav;

-- Index: representative_url_representative_id

-- DROP INDEX representative_url_representative_id;
";


declare function ti:WriteAsSQLInsert($family){
(
 concat("&#10;INSERT INTO representative_family_income (representative_id,AD_id,submission_date,HTML_Table) 
 VALUES (COALESCE((SELECT person_id FROM popit_personname WHERE name_ka='",$family/@po,"'),1),", replace($family/@id,"#",''),",",$family/@date,",") 
 ,$family
 ,")" 
 )
};
(: remove members which have exactly the same name from the family, we always only keep the oldest :)
declare function  ti:RemoveDoubles($members){ 
 let $fnlns := distinct-values( for $m in $members return <tr>{subsequence($m//td,1,2)}</tr>)
 return 
 if (count($fnlns)=count($members) )
 then $members
 else 
      for $name in $fnlns 
          let $eldest := (for $dob in $members[$name eq concat(td[1],td[2])]/td[4] order by $dob return $dob)[1]
          return ($members[td[4] eq $eldest])[1]  (: YES there are people who list themselves twice, so we remove them like this :)
};

declare function ti:EntrepeneurialIncome($row,$id,$col){


         let $row := tiUtil:GeorgianName2EnglishName($row/td[1],$row/td[2],$id,$col,$eng_col)  (: English version of the name :)
         
         (: this is a copy of the calculation for paid work, except the amount and dimension are in other fields :)
         let $incomedata:= $eng_col[.//@name='ADentrepreneurial_activity']//tr[td[last()] = $id]
            return sum((
                            for $gel in $incomedata[td[1]=$row/td[1] and td[2]=$row/td[2]  and td[8]= 'GEL'] //td[7]
                                return number($gel)
                            ,
                            for $usd in $incomedata[td[1]=$row/td[1] and td[2]=$row/td[2]  and td[8]= 'USD'] //td[7]
                                return number($usd) * $USD_GELexchange_rate 
                               
                            ))
};
declare function ti:MakeFamilyIncome($family){
for $fam in $family
    let $cars := 
        let $cardata:= $col[.//@name='ADmovable_property']//tr[td[last()] = $fam/@id]
        for $row in $fam//tr
            let $car := $cardata[td[1]=$row/td[1] and td[2]=$row/td[2] and td[4] = 'მსუბუქი ავტომანქანა' ]//td[5] 
            return
            if ($car) then <td>{string-join($car,'; ')}</td> else <td>-</td>
    let $incomes := 
        let $incomedata:= $col[.//@name='ADpaid_work']//tr[td[last()] = $fam/@id]
        for $row in $fam//tr
            let $inGEL := sum((
                            for $gel in $incomedata[td[1]=$row/td[1] and td[2]=$row/td[2]  and td[6]= 'GEL'] //td[5]
                                return number($gel)
                            ,
                            for $usd in $incomedata[td[1]=$row/td[1] and td[2]=$row/td[2]  and td[6]= 'USD'] //td[5]
                                return number($usd) * $USD_GELexchange_rate 
                             , ti:EntrepeneurialIncome($row,$fam/@id,$col)    
                            ))
            return
             
             if ( $inGEL) then $inGEL else 0 
    let $family_income := sum($incomes )
    let $fractions := for $i in $incomes return if ( $family_income = 0) then 0 else $i div $family_income
    let $ages := 
        let $submissiondate := $fam/@date
           for $row in $fam//tr return  tiUtil:AgeInYears($row/td[4],$submissiondate)
    let $genders := for $row in $fam//tr return  tiUtil:Gender($row//td[1])
    
    where $family_income ne 0   (: we exclude these :)
    order by $fractions[1]
     
    return
    
    <div po='{concat($fam//tr[1]//td[1]," ",$fam//tr[1]//td[2])}'>
    { $fam/@*,
    for $member at $pos in $fam//tr 
        let $incomefraction := round($fractions[$pos] * 100) div 100
        let $age := $ages[$pos]
        order by $incomefraction descending, $age descending
        return
    <tr>
    {
    (
     $member//td[1],
    $member//td[2],   
    if ($pos =1) then <td>{$public_official}</td> else $member//td[last()-1],
    $genders[$pos],
    <td>{if ($age = 666) then '?' else $age}</td>,
    <td>{round($incomefraction * 100)}</td>,
    <td>{round($incomes[$pos] * 100) div 100}</td>,
    <td>GEL</td>,
    $cars[$pos]
    )
    }
    </tr>
    }
    </div>
};


  
 
let  $ADheader :=  ($col[.//@name="ADheader"]//tr[contains(td[5],"საქართველოს პარლამენტი")]  )  (: subsequence($col[.//@name="ADheader"]//tr,1,1)    [td[last()] = '#47806'] :)

let $ADrelatives := $col[.//@name="ADfamily_relations"]//tr

let $families := 
    for $row in $ADheader
        let $ADid := $row//td[last()]
        let $relatives := $ADrelatives[td[last()]=$ADid]
        
        return
        <AD id='{$ADid}' date='{$row//td[last()-1]}'>
        {
        ti:RemoveDoubles(($row,$relatives)) (: remove members which have exactly the same name from the family, we always only keep the oldest :)
        }
        </AD>


 
return
 
 
 
 (:
 
 <root>{ti:MakeFamilyIncome($families)}</root>
 :)
 
  
 (:
First we make the data using ti:MakeFamilyIncome($families) (that takes a long time), then we transform it into other formats with the 
     statements below (very fast) 
     :)
let $doc := doc('Parliament_familyincome.xml')
return
  (:  ($SQLcreatetable,for $fam in $doc//div return  ti:WriteAsSQLInsert(ti:WriteAsNiceTable($fam))) :)(: for creating the SQL statements :)

(: for $fam in $doc//div return  ti:WriteAsNiceTable($fam)           :)       (: for creating the HTML view :)
 for $fam in $doc//div return   tiUtil:trTOcsv(ti:WriteAsCSVTable($fam))   (: for creating the csv :)
 
 




