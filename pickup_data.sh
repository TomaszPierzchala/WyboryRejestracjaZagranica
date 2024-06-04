#!/bin/sh

CURL="curl 'https://ewybory.msz.gov.pl/home/CommissionsList?countryId=__I__&typeOfVoting=Personally&_=__UNIX__' --compressed -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:126.0) Gecko/20100101 Firefox/126.0' -H 'Accept: text/html, */*; q=0.01' -H 'Accept-Language: pl,en-US;q=0.7,en;q=0.3' -H 'Accept-Encoding: gzip, deflate, br, zstd' -H 'Referer: https://ewybory.msz.gov.pl/zmien-miejsce-glosowania' -H 'X-Requested-With: XMLHttpRequest' -H 'Sec-Fetch-Dest: empty' -H 'Sec-Fetch-Mode: cors' -H 'Sec-Fetch-Site: same-origin' -H 'Connection: keep-alive' -H 'Cookie: ApplicationGatewayAffinityCORS=41dc337ab3e312fffcedd30c9a8613f7; ApplicationGatewayAffinity=41dc337ab3e312fffcedd30c9a8613f7; ASP.NET_SessionId=s0ltk5fl2waqenz4k21t5kwu; nlbi_3089413=G5mzV5IoLSoDX3/S1tTMqwAAAACxtpq5dvnKt5NeRv9pAl00; visid_incap_3089413=0Ljy0xJST9SGL7WBWRVr7UN0WGYAAAAAQ0IPAAAAAACA0LS0AcI78UyYPhPLyB3SJ+nPxLmw6vIU; incap_ses_7235_3089413=jLABeWwxXmHwjgHUOOJnZLa9XmYAAAAAg2pFTiCvGihMYl3RNj+2qQ==; contrast=false; size=a; nlbi_3089413_2147483394=F+GaAFCJMzAKYo5x1tTMqwAAAAB0UBA3iIcAqbdA3X2hIuTU; incap_ses_7234_3089413=dZi7TIa6bhH9CSMtulRkZNVfWmYAAAAAIoIuBny9lKFHd3A4Gvxb2w==; AcceptedPolicyJS=default; incap_ses_276_3089413=brvgRk6B7XEpCWWinozUAzf1XGYAAAAACcsrzx5gzAoOpRFY3vmPFg==; incap_ses_720_3089413=rTKGZmBmOD3P0dNmRPT9CUBKXmYAAAAA7ROIpfxTese46N+gNqiZjQ==; BIGipServer~MC-WIP~POOL-eWybory-public=rd4o00000000000000000000ffff0a0a2a12o443' -H 'Priority: u=1' -H 'TE: trailers'"
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

