
(: Script to turn the Intern spreadsheet of draftlaws into a nice looking HTML page

TODO: internal links are still not good and depend on the order in the spreadsheet.
The last number after the @ should just start from 1 and number the childlaws.

:)


declare namespace ti = "http://transparency.ge";


import module namespace tiUtil= "http://transparency.ge/XML-Utilities" at "/Users/admin/Documents/TIGeorgia/DeclarationsScraper/asset-declaration-scraper/scripts/XQueryTextMinerScripts/XMLUtilities.xquery";


declare variable $lang external;
declare variable $doc external;
declare variable $url external;

(: Be careful the positions of the TD's are 1 more than their position in the spreasdheet.
Somehow there is a dummy td in front :)

(: works nice, but can be nicer 
declare function ti:CreateID($date,$ID,$pos){string-join(for $i in ($date,$ID,string($pos)) return replace($i,' ',''),'')};
:)

declare function ti:CreateID($date,$ID,$pos,$parent){
    if ($parent) then 
        string-join(for $i in ($date,$ID) return replace($i,' ',''),'')
        else
        string-join(for $i in ($date,$ID,'@',string($pos)) return replace($i,' ',''),'')
        };

declare function ti:Spreadsheet2NicetableIndex($lang,$laws){
 

<div class='index'>
<table>
{
for $law at $pos in $laws (: debug subsequence($laws,1,2) :)
    let $title := normalize-space($law//td[6])
    let $date := tiUtil:toISOdate($law//td[2]) 
    let $id := $law//td[3]
    let $parent := contains($law//td[5],'*')
    let $hashid := ti:CreateID($date,$id,$pos,$parent)
    where $title
    order by $date descending
return
 
 
   
   
  
  <tr><td>{$date}</td>
    <td>{concat($id, if ($parent) then " (parent)" else "(child)")}</td>
    
      <td><a href="{concat($url,'#',$hashid)}">{$title}</a></td>
      <td>{string-join(for $i in $law//td[position() ge 10 and position() le 15] return 
            if (normalize-space($i/text()) eq '' ) then 'F' else 'T'
            ,
            ''
            )}</td>
      </tr>
      
   }
   
   
  </table>
  </div>
   
  };
  
  


declare function ti:Spreadsheet2Nicetable($lang,$laws,$language){
  
for $law at $pos in $laws (: debug subsequence($laws,1,2) :)
    let $title := normalize-space($law//td[6])
   let $date := tiUtil:toISOdate($law//td[2]) 
    let $id := $law//td[3]
    let $parent := contains($law//td[5],'*')
    let $hashid := ti:CreateID($date,$id,$pos,$parent)
    where $title
    order by $date descending
return
 
<div id='{$pos}'>
{ (
if ($parent) 
then 
  <h2 class='parent' id='{$hashid}'>{$title} (Parent law)</h2> 
else
    <h3  class='child' id='{$hashid}'>{$title} (Child law)</h3> 
  ,
  <table >
  {
  ( <tr><td>Links</td>
  <td>
  {
  ( <a href="{concat($url,'#', $hashid)}">This Law</a>
  ,
  if (not($parent))   (: add a link to the parent if it is a child law :)
    then  <div><span> </span><a href="{concat($url,'#',substring-before($hashid,'@'))}">Parent Law </a></div>
             
    else ''
    )
    }
    </td>
    </tr>
  ,
  for $at at $pos in $language
    let $value := normalize-space($law//td[$pos])
    where   $value ne '' and $pos ne 1 and $value ne '*'
    return <tr><td>{normalize-space($at)}</td><td>{$value}</td></tr>
  )  
  }
  </table>
 )
} 
  </div>
  };
  
  
  
let $doc:= doc($doc)

let $AttENG := $doc//tr[2]//td
let $AttGEO := $doc//tr[3]//td

let $laws := $doc//tr[position() gt 3]  (: just take the rows without header information :) 


(: now order the rows, by date, then by law number, then first the parent and then the children, and finally alphabetically by their name :)
let $laws := for $l in $laws order by $l//td[2] descending ,  $l//td[3], $l//td[5] descending , $l//td[6]  return $l 

let $ATT := if ($lang ='geo') then $AttGEO else $AttENG
return
  
  <div date='{current-dateTime()}'>
  {
  ti:Spreadsheet2NicetableIndex($lang,$laws),
   ti:Spreadsheet2Nicetable($lang,$laws,$ATT)
  }
  </div>



