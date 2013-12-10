let $votes := doc('VotesPerLaw.xml')
let $outcomes := doc('OutcomePerLaw.xml')

let $PassedlawOverview := doc('PassedlawOverview.xml')

let $outcometot := count($outcomes//tr)
(:
let $table := 
<table border='1'>
<tr>{for $a in ($outcomes//td)[1]/@* return <th>{name($a)} </th>}</tr>
{for $tr in $outcomes//tr return
<tr>
{for $a in 
</tr>
}

</table>
:)




(: Analysis of $outcomes :)
let $absent := $outcomes//@არესწრება
let $support := $outcomes//@მომხრე
let $against := $outcomes//@წინააღმდეგი

let $absentstat :=
<div>From the {$outcometot} votes for laws in our data set, {count($absent)} stated that some MP's were absent. On average, {round-half-to-even(avg($absent))} MP's were absent at a vote.
The maximum number of absent MP's was {max($absent)}, the minimum was {min($absent[. ne '0'])}.
</div>

let $supporters :=
<div>The average number of MP's supporting a law in our data set is {round-half-to-even(avg($support))}. The maximum was {max($support)}, the minimum was {min($support[. ne '0'])}.
</div>

let $againststat := 
<div>
Of the {$outcometot} votes for laws in our data set, {count($absent)} stated that MP's voted against. In {count($against[.='0'])} of these 0 MP's voted against the law.
Of the {count($against[. ne '0'])} laws that at least one MP voted against, the average, maximum and minumum number of votes against the law 
were {round-half-to-even(avg($against[. ne '0'])),', ',max($against[. ne '0']),' and ',min($against[. ne '0'])}, respectively.
</div>



(: analysis of $votes :)
let $cleanvotes := $votes//tr[count(td)=7]
let $parties := distinct-values($cleanvotes//td[5])




let $votetable :=
let $values := distinct-values($cleanvotes//td[7])
return
<table border='1'>
<caption>Number of votes for each distinct way of voting.</caption>
<tr><th>Vote</th><th>Count</th></tr>

{
for $v in $values 
    let $c := count($cleanvotes[td[7]=$v])
    order by $c descending
    return
    <tr><td>{$v}</td><td>{$c}</td></tr>
   }
   </table>
   
   
   let $partytable :=
let $values := distinct-values($cleanvotes//td[5])
return
<table border='1'>
<caption>Total number of votes for each party </caption>
<tr><th>Party</th><th>Count</th><th>დიახ</th><th>Not დიახ</th></tr>

{
for $v in $values 
    let $c := count($cleanvotes[td[5]=$v])
    let $yes := count($cleanvotes[td[5]=$v][td[7]='დიახ'])
    let $no := count($cleanvotes[td[5]=$v][td[7] ne 'დიახ'])
    order by $c descending
    return
    <tr><td>{$v}</td><td>{$c}</td><td>{$yes}</td><td>{$no}</td></tr>
   }
   </table>
   
   
    let $absenttable :=
let $values := distinct-values($cleanvotes//td[6])
return
<table border='1'>
<caption>Number of votes  per registration type.</caption>
<tr><th>Type</th><th>Count</th></tr>

{
for $v in $values 
    let $c := count($cleanvotes[td[6]=$v])
    order by $c descending
    return
    <tr><td>{$v}</td><td>{$c}</td></tr>
   }
   </table>
   
    let $titletable :=
let $values := distinct-values($cleanvotes//td[4])
return
<table border='1'>
<caption>Number of votes  per type of MP.</caption>
<tr><th>Type</th><th>Count</th><th>დიახ</th><th>Not დიახ</th></tr>

{
for $v in $values 
    let $c := count($cleanvotes[td[4]=$v])
   let $yes := count($cleanvotes[td[4]=$v][td[7]='დიახ'])
    let $no := count($cleanvotes[td[4]=$v][td[7] ne 'დიახ'])
    order by $c descending
    return
    <tr><td>{$v}</td><td>{$c}</td><td>{$yes}</td><td>{$no}</td></tr>
   }
   </table>
   
   
    let   $MPspertitletable := 
let $values := distinct-values($cleanvotes//td[4])
return
<table border='1'>
<caption>Number of different persons per type of MP.</caption>
<tr><th>Type</th><th>Count</th></tr>

{
for $v in $values 
    let $c := count(distinct-values(for $row in $cleanvotes[td[4]=$v] return <n>{concat($row/td[2],$row/td[3])}</n>))
     
    order by $c descending
    return
    <tr><td>{$v}</td><td>{$c}</td> </tr>
   }
   </table>
   
   
   let $lawspermonth :=
   <table border='1' id='votespermonth'>
   <caption>Number of laws voted on per month.</caption>
   {
    let $months := distinct-values(for $date in $PassedlawOverview//tr//td[1] return replace($date,'-..$',''))
    for $mon in $months 
        let $c := count($PassedlawOverview//tr[.//td[1][contains(.,$mon)]])
        order by $mon
        return <tr><td>{$mon}</td><td>{$c}</td></tr>
   }
   </table>
   
let $voteanalysis :=
<div id='vote'>
<h2>Analysis of votes</h2>
<p>This analysis is based on data extracted at {current-dateTime()}.</p>

<h3>Analysis of Votes per month</h3>
{$lawspermonth}

<h3>Analysis of  votes per person</h3>
Each of the {$outcometot} votes for laws in our data set has a document attached to it which indicates for each MP whether he or she was present and how he or she voted. 
We present a small analysis of these votes per MP. 
A total of {count($votes//tr)} lines of information is present in all these files, but not all of it is presented in a uniform format.
For our analysis, we only use the {count($cleanvotes)} number of lines for which we have the following information present:
<ol>
<li>First name, surname, function and pary affiliation of the MP, and </li>
<li>whether the MP registered for the particular vote, and how he or she voted.</li>
</ol>
All laws in our data set were passed and obtained a majority vote. 
We have a closer look at the voting results.
First we look at what types of votes were recorded and how often.
{$votetable}
<p>The next table shows how each faction in parliament voted.</p>
{$partytable}
<p>We saw above that the number of MPs that is absent at votes is quite high. The next table presents the different ways in which MPs are registered.</p>
{$absenttable}
<p>We can also look how MPs vote when we consider their function in parliament. First we see how many different persons we have in our data set for each function.
{$MPspertitletable}
In the next table we show how MPs in a particular function vote.
</p>
{$titletable}
</div>


(: now we count per person for how many laws he actually voted :)

let $personcount := 
<div id='mpcount'>
<h3>Analysis of the number of votes each MP attended</h3>
<table border='1'>
<caption>Number of laws each MP voted on.</caption>
<tr><th>MP</th><th>Count</th></tr>

{
 
let $people := for $row in $cleanvotes return <n n='{concat($row/td[2],' ',$row/td[3])}'>{($row/td[2],$row/td[3])}</n>
let $distinct-people := distinct-values($people//@n)
for $p in $distinct-people
    let $fn := ($people[@n=$p])[1]//td[1]
    let $sn := ($people[@n=$p])[1]//td[2]
    
    let $c := count($cleanvotes[td[2]=$fn][td[3]=$sn])
    
     order by $c descending
    return
    <tr><td>{$p}</td><td>{$c}</td> </tr>
}
   </table>
   
   </div>
   
   
return


( 
 $personcount,
<div id='votesperlaw'>
<h3>Analysis of  votes per law</h3>
{($absentstat,$supporters,$againststat)}
</div>,
$voteanalysis
)