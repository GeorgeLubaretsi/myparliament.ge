#!/bin/bash

### paths that need to be set
saxon="/usr/local/bin/saxon9he.jar"
PassedLawURL="http://parliament.ge/index.php?option=com_content&view=article&id=2840%3Alist-of-voting-records&catid=180%3Avoting-records&Itemid=5&lang=ge";


# Script to scrape the draft law overview from http://parliament.ge, then also scrape all lists of voting details and store these,
#finally we do an analysis with XQuery

# The initial output is a CSV $DraftlawOverview with 5 fields:   Output is inverse chronologically ordered.
#ISO-date   Law Number    Law Name  URL to Voting results    URL to Draft Law 
# We can use this file to create a nice webpage with an overview of passed laws.

# We also have the Outcomes and votes of all these laws in XML table format, and have an analysis of the voting results over all laws.



DraftlawOverview="PassedlawOverview.csv"
DraftlawOverviewXML="PassedlawOverview.xml"

VotesPerLaw="VotesPerLaw.xml";
VotesPerLawCSV="VotesPerLaw.csv";



OutcomePerLaw="OutcomePerLaw.xml";
OutcomePerLawCSV="OutcomePerLaw.csv";

# step 1 get the overview and create a CSv from it
curl "$PassedLawURL" |
sed -n '/^<table class="contentpaneopen">/,/<.table>/p' |   # only get the part we are interested in (without Viagra spam ;-) )
sed 's/&nbsp;/ /g'    > DraftlawOverview.xml

# Now call DraftlawOverview-Extractor.xquery and let it output to stdout and | sed '1d' write to $DraftlawOverview
java -cp "$saxon" net.sf.saxon.Query DraftlawOverview-Extractor.xquery  > "$DraftlawOverviewXML";  

java -cp "$saxon" net.sf.saxon.Query XML2CSV.xquery xml="$DraftlawOverviewXML" |sed '1d' > "$DraftlawOverview";


# step 2 Collect the voting records

# step 2.1 write them to nice XML files in the folder VotingRecordsRaw
mkdir VotingRecordsRaw
# create from the overview file, for each line a wget statement which saves the file, exdtracts the wanted XML from the docx zip file and removes the docx zip file again.
cat "$DraftlawOverview"  | awk -F$'\t' '{print "wget -O "$2" "$4"; unzip -p "$2" word/document.xml > VotingRecordsRaw/"$2".xml;rm "$2";sleep 2;"}' > TMPgetVotes;
bash TMPgetVotes;  # run all these statements
rm TMPgetVotes;
# throw away empty XML files  
#for f in VotingRecordsRaw/*;do if [  -s $f ]; then  true;else rm $f; fi;done
#BETTER: throw away all files which do not get through xmllint (use exit status)
for f in VotingRecordsRaw/*;do xmllint -noout $f; if [  $? != 0 ]; then  rm $f; fi;done;
sleep 10;
# step 3 now extract how everybody voted and the outcomes of each vote with the XQuery DraftLaw-VoteExtractor.xquery (which uses the files in VotingRecordsRaw)
java -Xmx2G -cp  "$saxon" net.sf.saxon.Query DraftLaw-VoteExtractor.xquery AnalysisType=outcome > $OutcomePerLaw
java -Xmx2G -cp  "$saxon" net.sf.saxon.Query DraftLaw-VoteExtractor.xquery AnalysisType=vote > $VotesPerLaw

# We could now remove the large directory with the raw votes
# rm -r VotingRecordsRaw 

# step 3a, also create csv versions of these files
java -cp  "$saxon" net.sf.saxon.Query XML2CSV.xquery xml="$OutcomePerLaw" |sed '1d' > "$OutcomePerLawCSV";
java -cp  "$saxon" net.sf.saxon.Query XML2CSV.xquery xml="$VotesPerLaw" |sed '1d' > "$VotesPerLawCSV";
# Next step ony needs the files $OutcomePerLaw and $VotesPerLaw
# Step 4 : then do the analysis with DraftLawvotingAnalysis.xquery which yields DraftLawvotingAnalysis.html
java -Xmx2G -cp  "$saxon" net.sf.saxon.Query DraftLawvotingAnalysis.xquery url="$PassedLawURL" > DraftLawvotingAnalysis.html

# gzip big files

gzip -f "$VotesPerLaw" "$VotesPerLawCSV" "$OutcomePerLaw" "$OutcomePerLawCSV"