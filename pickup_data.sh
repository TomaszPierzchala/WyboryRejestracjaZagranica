#!/bin/sh

CURL="curl 'https://ewybory.msz.gov.pl/home/CommissionsList?countryId=__I__&typeOfVoting=Personally&_=__UNIX__' --compressed -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/117.0' -H 'Accept: text/html, */*; q=0.01' -H 'Accept-Language: pl,en-US;q=0.7,en;q=0.3' -H 'Accept-Encoding: gzip, deflate, br' -H 'X-Requested-With: XMLHttpRequest' -H 'Connection: keep-alive' -H 'Referer: https://ewybory.msz.gov.pl/zmien-miejsce-glosowania' -H 'Cookie: ApplicationGatewayAffinityCORS=41dc337ab3e312fffcedd30c9a8613f7; ApplicationGatewayAffinity=41dc337ab3e312fffcedd30c9a8613f7; contrast=false; size=a; ASP.NET_SessionId=hceauektisrhwhgru43uabzo; AcceptedPolicyJS=default; BIGipServer~MC-WIP~POOL-eWybory-public=rd4o00000000000000000000ffff0a0a2a05o443' -H 'Sec-Fetch-Dest: empty' -H 'Sec-Fetch-Mode: cors' -H 'Sec-Fetch-Site: same-origin' -H 'TE: trailers'"

EPOCH="$(( $(date -j -v -1d +%s) * 1000 ))"
#set -x
source getCountry.sh

rm ranking.out
export LANG="pl_PL.UTF-8"
sum=0
obwody=0
s_country=0
for i in {2..100};
do
	[[ $(( i % 10 )) -eq 0 ]] && [[ -z $1 ]] && printf "Wykonano %d%%\r" "$i"
	res=$(eval $(echo "$CURL"| sed "s/__I__/$i/g; s/__UNIX__/$EPOCH/g") 2>/dev/null);
	[[ "$res" =~ "brak dostępnych komisji o wybranym sposobie głosowania" ]] && continue
	ilosc=`echo $res |grep -E -A2 "liczba zarejestrowanych"  | grep -oE '>[[:digit:]]+<'| grep -oE [[:digit:]]+ `

	add=0
	while read -r il; do
	   add=$((add + il))
	   obwody=$((obwody + 1))
	done <<< "$ilosc"
	sum=$((sum + add))
	s_country=$((s_country + 1))
	name=`getCountry $i`
	echo $name, $add, $i >> ranking.out
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

