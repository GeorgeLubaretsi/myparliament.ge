
(:  
 
 Compute the properties, assets, family status and expenses for an MP based on Asset Declarations
 Create UPDATE statements for MyParliament DB
  
:)



declare namespace ti = "http://transparency.ge";
declare namespace xsd="http://www.w3.org/2001/XMLSchema";

import module namespace tiUtil= "http://transparency.ge/XML-Utilities" at 
      "https://raw.github.com/tigeorgia/asset-declaration-scraper/master/scripts/XQueryTextMinerScripts/XMLUtilities.xquery"; (: note how to create this link from the git address. The git address brings you to the HTML page! :)
      
(: LOCAL "/Users/admin/Documents/TIGeorgia/DeclarationsScraper/asset-declaration-scraper/scripts/XQueryTextMinerScripts/XMLUtilities.xquery"; :) 


declare option saxon:output "method=text";  (: output as text without xml header :)
declare option saxon:output    "omit-xml-declaration=yes";



declare variable $language := "geo"; (: eng|geo :) 
declare variable $public_official := if ($language = 'eng') then 'Public Official' else 'საჯარო თანამდებობის პირის';
declare variable $ADbaseurl := "https://declaration.gov.ge/declaration?id=";
declare variable $ADbaseurlENG := "https://declaration.gov.ge/eng/declaration?id=";




declare variable $colpath  external; (:'/Users/admin/Documents/TIGeorgia/DeclarationsScraper/Spreadsheets/xml/ka' ;  :)
declare variable $colpath_english external;  (: '/Users/admin/Documents/TIGeorgia/DeclarationsScraper/Spreadsheets/xml/en' :)  
declare variable $outputtype  external; (: 'sql'; (: :) :)
declare variable $col := collection($colpath);
declare variable $eng_col := collection($colpath_english) ; 
  
  
 


declare function ti:WriteAsSQLInsert($mprow){

(: Our goal 
INSERT INTO incomedeclaration_declarationtotalincome (representative_id,ad_id,ad_submission_date,ad_entrepreneurial_income,ad_paid_work_income)
 VALUES ((SELECT person_id FROM popit_personname WHERE name_ka='აზერ სულეიმანოვი'),45799,TO_DATE('2013-05-13','YYYY-MM-DD'),0,53776.03);
:) 
 

 concat("&#10;INSERT INTO representative_representative  (representative_id,declaration_id,family_status, expenses, property_assets ) 
 VALUES ((SELECT person_id FROM popit_personname WHERE name_ka='",normalize-space($mprow[1]),"'),", 
 string-join((replace($mprow[2],"#",''), subsequence($mprow,3)),   ","),
 ");" 
 )
};

declare function ti:WriteAsSQLUpdate($mprow){

(: Our goal 

UPDATE table_name
SET column1=value1,column2=value2,...
WHERE some_column=some_value;
:) 
 let $where := concat("&#10;WHERE  representative_id=", "(SELECT person_id FROM popit_personname WHERE name_ka='",normalize-space($mprow[1]),"')")
 let $setvalues := string-join(
 (
 string-join(("declaration_id",replace($mprow[2],"#",'') ),'='),
 string-join(("family_status",$mprow[3] ),'='),
 string-join(("expenses",$mprow[4] ),'='),
 string-join(("property_assets",$mprow[5] ),'=')
 )
 ,',&#10;    ') 

return
 concat("&#10;UPDATE representative_representative 
SET ",$setvalues,$where ,  ";" )
};

(:

:)


 
(: write output either as csv, or as sql insert statements :)
declare function ti:MPdata($outputtype){ 
 
let  $ADheader :=  $col[.//@name="ADheader"]//tr
    [contains(td[5],"საქართველოს პარლამენტი")] (: Just parliamnet [contains(td[5],"საქართველოს პარლამენტი")]  :)  
    [td[last()-1] ge '2012-10-01']  (: only from after 2012 election :)
   
let $ADrealestate := $col[.//@name="ADreal_estate"]//tr 
let $ADmovable_property :=   $col[.//@name="ADmovable_property"]//tr   (: ADmovable_property :) 

let $ADincome_or_expenditures :=   $col[.//@name="ADincome_or_expenditures"]//tr[contains(.//td[last()-1],'გასავალი')]
 
 
return
 
    distinct-values(
    for $row   in $ADheader
        let $ADid := $row//td[last()]
        let $name := concat($row//td[1]," ",$row//td[2])
        let $date := $row//td[last()-1]
        let $famstat := if ($col[.//@name="ADfamily_relations"][.//td[last()]=$ADid][.//td[last()-1]= "მეუღლე"]) then "married" else 'unmarried'
        let $realestate := 
           tiUtil:NotEmpty(string-join(for $r in $ADrealestate[.//td[last()]=$ADid] return string-join(subsequence($r//td,4,2),", "),"; ")  )
        let $movprop :=    (string-join(for $r in $ADmovable_property[.//td[last()]=$ADid] return string-join(subsequence($r//td,4,2),", "),"; ")  )
          
        let $expenses :=   tiUtil:NotEmpty(string-join(for $r in $ADincome_or_expenditures[.//td[last()]=$ADid] return 
                                replace(string-join(subsequence($r//td,3,3),", "),'გასავალი,', '') ,"; " ))
        let $out :=  ($name, $ADid, for $i in ($famstat,$expenses, tiUtil:NotEmpty(string-join(($realestate,$movprop),'; ')))
                     return tiUtil:QuotesAround($i) 
                     )
        where not( $ADheader[td[1] = $row/td[1] and td[2]=$row/td[2] and td[last()-1] gt $date])  (: so only take the last submitted AD :)
              and (: not(matches(normalize-space($name),'^$')) :) matches(normalize-space($name),' ') (: should contain at least a space :)
        order by $name
        return
        if ($outputtype='csv') then
        concat('&#10;',string-join($out, '&#09;'))
        else
        ti:WriteAsSQLUpdate($out)  
    )    

        };
 
 
 
ti:MPdata($outputtype) 

  