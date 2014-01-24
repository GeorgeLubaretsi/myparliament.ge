module namespace FaminAD = "http://transparency.ge/AssetDeclarations/FamilyIncme";



(:  


A fantastic example is https://declaration.gov.ge/eng/declaration?id=48161
 
 
    

GEORGIAN VERSION

OUTPUT schema for CSV

Every row describes the income of each member of a family. All rows with the same  Asset Declaration ID constitute one family.

First Name;Last Name;Family Role;Gender;Age;% Household Income;Income;Car;Name of Public Official;Organization of Public Official;Asset Declaration ID;Date of Submission of Asset DEclaration


:)

declare namespace ti = "http://transparency.ge";
declare namespace xsd="http://www.w3.org/2001/XMLSchema";
import module namespace tiUtil= "http://transparency.ge/XML-Utilities" at 
      "https://raw.github.com/tigeorgia/asset-declaration-scraper/master/scripts/XQueryTextMinerScripts/XMLUtilities.xquery";
      
declare variable $FaminAD:USD_GELexchange_rate  := number(1.65); (: see http://www.xe.com/currencycharts/?from=USD&to=GEL&view=5Y , we guessed the average in the period 2010-2013 :)
declare variable $FaminAD:language := "geo"; (: eng|geo :) 
declare variable $FaminAD:public_official := if ($FaminAD:language = 'eng') then 'Public Official' else 'საჯარო თანამდებობის პირის';
declare variable $FaminAD:ADbaseurl := "https://declaration.gov.ge/declaration?id=";
declare variable $FaminAD:ADbaseurlENG := "https://declaration.gov.ge/eng/declaration?id=";




declare variable $colpath external; (:  '/Users/admin/Documents/TIGeorgia/DeclarationsScraper/Spreadsheets/xml/ka' ;  :)
declare variable $colpath_english external;  (: '/Users/admin/Documents/TIGeorgia/DeclarationsScraper/Spreadsheets/xml/en' :)
declare variable $outputtype external;
declare variable $col := collection($colpath);
declare variable $eng_col := collection($colpath_english) ;
  
declare variable $FaminAD:col := collection($colpath); ;
declare variable $FaminAD:eng_col := collection($colpath_english) ;
declare variable  $FaminAD:English_Ent_Activity := $eng_col[.//@name='ADentrepreneurial_activity'];
 
(: given a row in $ADheader (which denotes one public official and one Asset Declaration), compute the total family income of that person/asset declaration :)

declare function FaminAD:ComputeFamilyIncome($row,$ADid,$col){  (: $ADid should match with that of the row, ootherwise it does not make sense :)
(:let $ADid := $row//td[last()]  :)
let $relatives := tiUtil:relatives($ADid,$col)
let $family :=    FaminAD:RemoveDoubles(($row,$relatives)) 
let $incomedata:= $col[.//@name='ADpaid_work']//tr[td[last()] = $ADid]
let $incomes := 
        
        for $row in $family
            let $inGEL := sum((
                            for $gel in $incomedata[td[1]=$row/td[1] and td[2]=$row/td[2]  and td[6]= 'GEL'] //td[5]
                                return number($gel)
                            ,
                            for $usd in $incomedata[td[1]=$row/td[1] and td[2]=$row/td[2]  and td[6]= 'USD'] //td[5]
                                return number($usd) * $FaminAD:USD_GELexchange_rate 
                             , 
                             FaminAD:EntrepeneurialIncome($row,$ADid,$col)    
                            ))
            return
             
             if ( $inGEL) then $inGEL else 0 
return
  sum($incomes)
};

(: given a row in $ADheader (which denotes one public official and one Asset Declaration), compute the total  income of that person/asset declaration :)
declare function FaminAD:ComputeTotalIncome($row,$ADid,$col){
(:let $ADid := $row//td[last()]  :)
let $incomedata:= $col[.//@name='ADpaid_work']//tr[td[last()] = $ADid]
let $inGEL := sum((
                            for $gel in $incomedata[td[1]=$row/td[1] and td[2]=$row/td[2]  and td[6]= 'GEL'] //td[5]
                                return number($gel)
                            ,
                            for $usd in $incomedata[td[1]=$row/td[1] and td[2]=$row/td[2]  and td[6]= 'USD'] //td[5]
                                return number($usd) * $FaminAD:USD_GELexchange_rate 
                             , 
                             FaminAD:EntrepeneurialIncome($row,$ADid,$col)    
                            ))
            
return
  $inGEL
};
 
 
declare function FaminAD:WriteAsNiceTable($family){
(: delete names when we delete the names again :)
<table class='family_income' border='1' >
{
($family/@*,
<tr>
  <th>First Name</th><th>Last Name</th>  
<th>Family Role</th><th>Gender</th><th>Age</th><th>% Household Income</th><th>Income</th><th></th><th>Car</th></tr>,
<caption>Income of the household of {string($family/@po)} declared at {string($family/@date)} (<a href="{concat($FaminAD:ADbaseurl,replace($family/@id,"#",''))}">Source (geo)</a>) 
(<a href="{concat($FaminAD:ADbaseurlENG,replace($family/@id,"#",''))}">Source (eng)</a>). Public Official at {string($family/@org)}.</caption> ,
$family//tr
)
}
</table>
};

declare function FaminAD:WriteAsCSVTable($family){
<table>
{
for $tr in $family//tr return
    <tr>{(
         $tr//td,
         for $at in  $family/@* return <td>{string($at)}</td>)}
    </tr>
}
</table>

};

declare variable $FaminAD:SQLcreatetable := "
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


declare function FaminAD:WriteAsSQLInsert($family){
(
 concat("&#10;INSERT INTO representative_family_income (representative_id,AD_id,submission_date,HTML_Table) 
 VALUES (COALESCE((SELECT person_id FROM popit_personname WHERE name_ka='",$family/@po,"'),1),", replace($family/@id,"#",''),",",$family/@date,",") 
 ,$family
 ,")" 
 )
};
(: remove members which have exactly the same name from the family, we always only keep the oldest :)
declare function  FaminAD:RemoveDoubles($members){ 
 let $fnlns := distinct-values( for $m in $members return <tr>{subsequence($m//td,1,2)}</tr>)
 return 
 if (count($fnlns)=count($members) )
 then $members
 else 
      for $name in $fnlns 
          let $eldest := (for $dob in $members[$name eq concat(td[1],td[2])]/td[4] order by $dob return $dob)[1]
          return ($members[td[4] eq $eldest])[1]  (: YES there are people who list themselves twice, so we remove them like this :)
};

declare function FaminAD:EntrepeneurialIncome($row,$id,$col){

         
         let $row := 
            if ($col = $FaminAD:col)  (: we use the Georgian collection, and thus have to convert the names :)
            then
            tiUtil:GeorgianName2EnglishName($row/td[1],$row/td[2],$id,$col,$FaminAD:eng_col)  (: English version of the name :)
            else
            $row
            
         (: this is a copy of the calculation for paid work, except the amount and dimension are in other fields :)
         let $incomedata:= $FaminAD:eng_col[.//@name='ADentrepreneurial_activity']//tr[td[last()] = $id]
            return sum((
                            for $gel in $incomedata[td[1]=$row/td[1] and td[2]=$row/td[2]  and td[8]= 'GEL'] //td[7]
                                return number($gel)
                            ,
                            for $usd in $incomedata[td[1]=$row/td[1] and td[2]=$row/td[2]  and td[8]= 'USD'] //td[7]
                                return number($usd) * $FaminAD:USD_GELexchange_rate 
                               
                            ))
};
declare function FaminAD:MakeFamilyIncome($family){
for $fam in $family
    let $cars := 
        let $cardata:= $FaminAD:col[.//@name='ADmovable_property']//tr[td[last()] = $fam/@id]
        for $row in $fam//tr
            let $car := $cardata[td[1]=$row/td[1] and td[2]=$row/td[2] and td[4] = 'მსუბუქი ავტომანქანა' ]//td[5] 
            return
            if ($car) then <td>{string-join($car,'; ')}</td> else <td>-</td>
    let $incomes := 
        let $incomedata:= $FaminAD:col[.//@name='ADpaid_work']//tr[td[last()] = $fam/@id]
        for $row in $fam//tr
            let $inGEL := sum((
                            for $gel in $incomedata[td[1]=$row/td[1] and td[2]=$row/td[2]  and td[6]= 'GEL'] //td[5]
                                return number($gel)
                            ,
                            for $usd in $incomedata[td[1]=$row/td[1] and td[2]=$row/td[2]  and td[6]= 'USD'] //td[5]
                                return number($usd) * $FaminAD:USD_GELexchange_rate 
                             , 
                             FaminAD:EntrepeneurialIncome($row,$fam/@id,$FaminAD:col)    
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
    
    <div po='{concat($fam//tr[1]//td[1]," ",$fam//tr[1]//td[2])}'  org='{$fam//tr[1]//td[5]}'>
    { $fam/@*,
    for $member at $pos in $fam//tr 
        let $incomefraction := round($fractions[$pos] * 100) div 100
        let $age := $ages[$pos]
        order by $incomefraction descending, $age descending
        return
    <tr>
    {
    (
    (:  TEMP commented out the first and last names :)  $member//td[1],
    $member//td[2],    
    if ($pos =1) then <td>{$FaminAD:public_official}</td> else $member//td[last()-1],
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


  