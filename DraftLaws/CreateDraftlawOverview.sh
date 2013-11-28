
# Script to scrape the draft law overview from http://parliament.ge

# The output is a CSV with four fields:   Output is inverse chronologically ordered.
#ISO-date   Draft-law Number    Draft-law Name  URL to Draft Law


curl 'http://parliament.ge/index.php?option=com_content&view=article&id=2840%3Alist-of-voting-records&catid=180%3Avoting-records&Itemid=5&lang=ge' |
|sed -n '/^<table class="contentpaneopen">/,/<.table>/p' |   # only get the part we are interested in (without Viagra spam ;-) )
sed 's/&nbsp;/ /g'    > DraftlawOverview.xml

# Now call DraftlawOverview-Extractor.xquery and let it output to stdout and | sed '1d'


# Part 2, create a list of voting records for each draft law

# loop over all lines inthe previous spreadsheet

# get the url from the previous spreadsheet and the draftlawID: using awk
draftlawID=" 
url="
outfile=`echo $url   | sed 's%http://parliament.ge/files/Voting_Records/%%; s%[./]%-%g'`

wget  -O "$outfile"  $url 
unzip -p "$outfile" word/document.xml > "Soutfile.xml"

# Now run  DraftlawVote-Extractor.xquery on "Soutfile.xml" and that gives the outcome of the vote plus the individual votes of all guys
