#!/bin/sh

CURL="curl 'https://ewybory.msz.gov.pl/api/configuration/getCommissions?typeOfVoting=1&countryId=__I__' --compressed -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:138.0) Gecko/20100101 Firefox/138.0' -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: pl,en-US;q=0.7,en;q=0.3' -H 'Accept-Encoding: gzip, deflate, br, zstd' -H 'Connection: keep-alive' -H 'Referer: https://ewybory.msz.gov.pl/nowa-rejestracja' -H 'Cookie: ApplicationGatewayAffinityCORS=41dc337ab3e312fffcedd30c9a8613f7; ApplicationGatewayAffinity=41dc337ab3e312fffcedd30c9a8613f7; ASP.NET_SessionId=s0ltk5fl2waqenz4k21t5kwu; nlbi_3089413=G5mzV5IoLSoDX3/S1tTMqwAAAACxtpq5dvnKt5NeRv9pAl00; nlbi_3089413_2147483394=6v9ObiqnyTZeiG5u1tTMqwAAAAD8yPGJRTulf49iuJX7oHe9; visid_incap_3089413=7S7EtprRSQSXrSyLV1o2GX4eH2gAAAAAQUIPAAAAAABbhbWARYTsn1dAjUOeimUV; incap_ses_260_3089413=l1lGLFMvshpK3+9N17SbAx2PIGgAAAAA4dRdaQElyTz0iYZBbHX00w==; cookiesConsent=all; BIGipServer~MC-WIP~POOL-eWybory-public=rd4o00000000000000000000ffff0a0a2a05o443' -H 'Sec-Fetch-Dest: empty' -H 'Sec-Fetch-Mode: cors' -H 'Sec-Fetch-Site: same-origin' -H 'Priority: u=0' -H 'TE: trailers'"
#set -x
source getCountry.sh

rm ranking.out
export LANG="pl_PL.UTF-8"
sum=0
obwody=0
s_country=0
last=`sort -k1g kraje |tail -1 |cut -f1 -d" "`
for i in $(seq 1 $last);
do
    [[ $(( i % 10 )) -eq 0 ]] && [[ -z $1 ]] && printf "Wykonano %d%%\r" "$((i * 100 / last))"
    
    country=`getCountry $i`
    countryId=`echo $country | cut -f1 -d" "`
    countryName=`echo $country | cut -f2- -d" "`
	#echo countryId $countryId countryName $countryName
    sleep 0.05
    res=$(eval $(echo "$CURL"| sed "s/__I__/$countryId/g;") 2>/dev/null);
	
	[[ "$res" =~ "html" || "$(echo "$res" | jq '(.commissions | length) == 0')" == "true" ]] && continue
	#[[ "$res" =~ "html" ]] && echo "ERROR : $countryName" && continue
    #[[ "$(echo "$res" | jq '(.commissions | length) == 0')" == "true" ]] && echo ERROR :  $countryName "[]=0" && continue
	
	ilosc=$(echo "$res" | jq -r '.commissions[].acceptedRegistrationsCount')
	
	#echo countryName $countryName ilosc $ilosc
	add=0
	while read -r il; do
	   add=$((add + il))
	   obwody=$((obwody + 1))
	done <<< "$ilosc"
	sum=$((sum + add))
	s_country=$((s_country + 1))
	echo $countryName, $add, $countryId >> ranking.out
	
done
if [ -z $1 ]; then
 echo ""
 date
 printf "Liczba zarejestrowanych za granicą %'d w %d krajach ( w %d obwodach ).\n" "$sum" "$s_country" "$obwody"
else
 echo `date`,$sum,$s_country,$obwody >> wyniki.out
fi
sort -k 2 -t , -g -r ranking.out > ranking.sorted

source calc_ranking.sh
zestawienie $sum

