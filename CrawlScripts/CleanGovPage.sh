#!/bin/bash


# Purpose clean a parliament.ge file 
url=$1


 
        out=`echo $url|sed 's/[^0-9]//g; s/$/.xml/'`;
        echo $out;
        # rm "$out"; #remove the out file if it exists already
        echo "<!-- Downloaded from $url -->" > "$out";
        curl "$url" |
         
        sed -n '/^<table class="contentpaneopen">/,/<.table>/p' |   # only get the part we are interested in (without Viagra spam ;-) )
        sed 's/&nbsp;/ /g'  |
        tidy -raw -utf8 -n -asxml  >> "$out";
  