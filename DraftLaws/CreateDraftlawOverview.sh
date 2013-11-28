
# Script to scrape the draft law overview from http://parliament.ge

# The output is a CSV with four fields:   Output is inverse chronologically ordered.
#ISO-date   Draft-law Number    Draft-law Name  URL to Draft Law


curl 'http://parliament.ge/index.php?option=com_content&view=article&id=2840%3Alist-of-voting-records&catid=180%3Avoting-records&Itemid=5&lang=ge' |
|sed -n '/^<table class="contentpaneopen">/,/<.table>/p' |   # only get the part we are interested in (without Viagra spam ;-) )
sed 's/&nbsp;/ /g'    > DraftlawOverview.xml

# Now call DraftlawOverview-Extractor.xquery and let it output to stdout and | sed '1d'