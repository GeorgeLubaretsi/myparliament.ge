AUTHKEY=`curl https://www.google.com/accounts/ClientLogin -d Email=maartenmarx@gmail.com -d Passwd=XXXX -d accountType=HOSTED_OR_GOOGLE  -d source=cURL-Example -d service=wise|
tr -d '\n' | sed 's/.*Auth=//'`;



spreadsheetkey="0AtLaNvIaw4_rdEZkRWlDX2RhTlF6NEx5SU10Vll2R3c";
sheet="#gid=3";

curl -L --silent --header "Authorization: GoogleLogin auth=$AUTHKEY" "http://spreadsheets.google.com/feeds/download/spreadsheets/Export?key=$spreadsheetkey&exportFormat=html&gid=3"|
grep -P  -o "<table .*</table>" 


 