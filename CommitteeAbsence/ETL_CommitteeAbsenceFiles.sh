
# files downloaded with wget -nd -np -r 'http://www.parliament.ge/index.php?option=com_content&view=category&id=135&Itemid=110&lang=en' (but that goes on a bit too long. Shouls set the depth.

mkdir "CommitteeAbsence";

wget -nd -np -r  -l2 -P 'CommitteeAbsence' 'http://www.parliament.ge/index.php?option=com_content&view=category&id=135&Itemid=110&lang=en';

outdir="RawAbsenceCommittees"

mkdir "$outdir"
for file in CommitteeAbsence/*view=article*absences-committees*lang=en ; 
    do
        out=`echo $file|sed 's/^.*&id=//; s/-.*$/.xml/'`
        cat $file |
        sed -n '/^<table class="contentpaneopen">/,/<.table>/p' |   # only get the part we are interested in (without Viagra spam ;-) )
        sed 's/&nbsp;/ /g'  |
        tidy -raw -utf8 -n -asxml  > "$outdir/$out";
        
    done;
# delete the downloaded files again    
rm -r    "CommitteeAbsence"; 
 # Then after downloading, run ExtractCommitteeAbsence.xquery and it creates  CommitteeAbsence.csv 
 java -cp /usr/local/bin/saxon9he.jar net.sf.saxon.Query ExtractCommitteeAbsence.xquery > CommitteeAbsence.xml;
 java -cp /usr/local/bin/saxon9he.jar net.sf.saxon.Query XML2CSV.xquery > CommitteeAbsence.csv;