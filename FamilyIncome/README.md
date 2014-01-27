Code to create  all kind of updates for the representatives based on the Asset Declarations
 #1) MPincome
 #2) Properties, assets,family status and expenses
 #3) urls/links to asset declarations, parliament page, and social media
 #4) Total incomes and assets of the family members (old family income HTML table)
the total income AND family income of a person given his Asset Declaration.


Run MPincome.sh (this may take a while)
Set hard paths only in MPincome.sh
Output SQL script is in RepresentativeTableUpdate.sql


## Descriptions of scripts
MPincome
Run MPincome.sh to create a new set of SQL insert statements making the table representative_total_income
given the current Asset DEclarations.
This tabel gives for each MP his income from salaries (paid work income) and from entrepeneurial activities, and the ID of the Asset declaration and the submission date of the Asset DEclaration.
Only the last submitted AD of the MP is used. In the calculation we convert USD icome to GEL using an exchange rate of 1.65. Other currencies are ignored (they hardly ever (if at all) occur).

FAMILY INCOME
The code generates an XML file based on all Asset DEclarations.
From these a HTML, CSV and SQL imprt statements view is generated.

In the present version of FamilyIncome.xquery a filter is set to only run it on members of Parliament. 

The script takes very long to run.

Hard paths to Asset dEclaration data and to XML utilities need to be reset.
 
