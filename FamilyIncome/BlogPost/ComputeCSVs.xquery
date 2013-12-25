(: Xquery for computing the information in  http://politicalmashup.nl/2013/12/household-income-in-georgian-asset-declarations/ :)


let $doc := doc('AllAD_familyincome2.xml')
let $moneys := (0,10,25, 50, 75, 100,150,200,250,500,1000,2000,5000,10000,20000)
return
(
count($doc//div),'&#10;',
for $i in (0,10,20,30,40,50,60,70,80,90,100)  return 
concat('&#10;',string($i),',',
count($doc//div[.//tr[td = 'საჯარო თანამდებობის პირის'][number(td[6]) ge $i and number(td[6]) lt $i +10 ]]) (: number of Public Officlas without income :)
)
,'&#10;',
for $i in  $moneys return 
concat('&#10;',string($i*1000),',',
count($doc//div[.//tr[number(td[7]) ge $i*1000   ]])  
)

,'&#10;',
for $i at $pos in  $moneys  return 
concat('&#10;',string($i*1000),',',
count($doc//div[sum(.//tr//td[7][. ne 'GEL']) ge $i*1000  and  sum(.//tr//td[7][. ne 'GEL']) lt $moneys[$pos +1]*1000])  
)
,

'&#10;',
for $i in  $moneys return 
concat('&#10;',string($i*1000),',',
count($doc//div[.//tr[./td[3][. ne "საჯარო თანამდებობის პირის"]][number(td[7]) ge $i*1000   ]])  
)
 
)