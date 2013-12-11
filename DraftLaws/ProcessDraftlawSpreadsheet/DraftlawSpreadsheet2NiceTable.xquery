
(: Script to turn the Intern spreadsheet of draftlaws into a nice looking HTML page :)


declare namespace ti = "http://transparency.ge";


import module namespace tiUtil= "http://transparency.ge/XML-Utilities" at "/Users/admin/Documents/TIGeorgia/DeclarationsScraper/asset-declaration-scraper/scripts/XQueryTextMinerScripts/XMLUtilities.xquery";


declare variable $lang external;
declare variable $doc external;
declare variable $url external;

(: Be careful the positions of the TD's are 1 more than their position in the spreasdheet.
Somehow there is a dummy td in front :)




declare function ti:Spreadsheet2NicetableIndex($lang,$doc){
 
let $doc:= doc($doc)

let $AttENG := $doc//tr[2]//td
let $AttGEO := $doc//tr[3]//td

let $laws := $doc//tr[position() gt 3]

let $ATT := if ($lang ='geo') then $AttGEO else $AttENG
return
<div class='index'>
<table>
{
for $law at $pos in $laws (: debug subsequence($laws,1,2) :)
    let $title := normalize-space($law//td[6])
    let $date := tiUtil:toISOdate($law//td[2]) 
    where $title
    order by $date descending
return
 
 
   
   
  
  <tr><td>{$date}</td>
      <td><a href="{concat($url,'#',$pos)}">{$title}</a></td>
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
  
  


declare function ti:Spreadsheet2Nicetable($lang,$doc){
 
let $doc:= doc($doc)

let $AttENG := $doc//tr[2]//td
let $AttGEO := $doc//tr[3]//td

let $laws := $doc//tr[position() gt 3]

let $ATT := if ($lang ='geo') then $AttGEO else $AttENG
return
for $law at $pos in $laws (: debug subsequence($laws,1,2) :)
    let $title := normalize-space($law//td[6])
   let $date := tiUtil:toISOdate($law//td[2]) 
    where $title
    order by $date descending
return
 
<div id='{$pos}'>
  <h3 id='{$pos}'>{$title}</h3> 
  <table >
  {
  for $at at $pos in $ATT
    let $value := normalize-space($law//td[$pos])
    where   $value ne '' and $pos ne 1 and $value ne '*'
    return <tr><td>{normalize-space($at)}</td><td>{$value}</td></tr>
  }
  </table>
  
  </div>
  };
  
  
  
  
  
  <div date='{current-dateTime()}'>
  {
  ti:Spreadsheet2NicetableIndex($lang,$doc),
   ti:Spreadsheet2Nicetable($lang,$doc)
  }
  </div>



