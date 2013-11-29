
# Script to scrape the draft law overview from http://parliament.ge

# The output is a CSV $DraftlawOverview with four fields:   Output is inverse chronologically ordered.
#ISO-date   Draft-law Number    Draft-law Name  URL to Draft Law

DraftlawOverview="DraftlawOverview.csv"

# step 1 get the overview and create a CSv from it
curl 'http://parliament.ge/index.php?option=com_content&view=article&id=2840%3Alist-of-voting-records&catid=180%3Avoting-records&Itemid=5&lang=ge' |
|sed -n '/^<table class="contentpaneopen">/,/<.table>/p' |   # only get the part we are interested in (without Viagra spam ;-) )
sed 's/&nbsp;/ /g'    > DraftlawOverview.xml

# Now call DraftlawOverview-Extractor.xquery and let it output to stdout and | sed '1d' write to $DraftlawOverview



# step 2 Collect the voting records

# step 2.1 write them to nice XML files in the folder VotingRecordsRaw
mkdir VotingRecordsRaw
cat "$DraftlawOverview"  | awk -F$'\t' '{print "wget -O "$2" "$4"; unzip -p "$2" word/document.xml > VotingRecordsRaw/"$2".xml;rm "$2";"}' > TMPgetVotes;
bash TMPgetVotes;
rm TMPgetVotes;
# throw away empty XML files  
#for f in VotingRecordsRaw/*;do if [  -s $f ]; then  true;else rm $f; fi;done
#BETTER: throw away all files which do not get through xmllint (use exit status)
for f in VotingRecordsRaw/*;do xmllint -noout $f; if [  $? != 0 ]; then  rm $f; fi;done
# step 3 now extract how everybody voted and the outcomes of each vote with the XQuery DraftLaw-VoteExtractor.xquery



