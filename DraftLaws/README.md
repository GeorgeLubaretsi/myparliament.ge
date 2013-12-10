Create an Overview of Passed laws and do an analysis on them

Script can be run every week(end) to be up to date.

Dependencies:
    * Saxon.jar path must be set in CreateDraftlawOverview.sh
    * $PassedLawURL is the page of the passed laws on which the scraper is based.
    
Script generates spreadsheets in xml and csv format:

From PassedlawOverview.csv a page of passed laws can be made. It contains law-id's, law-names, links to the voting record and the law text, and the date of passing the law.

 OutcomePerLaw.csv gives for each lawID the outcome
 
 VotesPerLaw.csv gives for each lawID and each MP who was present at the vote how he voted (big file)
 
 These last two should be made available to the public, together with DraftLawvotingAnalysis.html which gives an analysis of the voting behaviour of the MP's.