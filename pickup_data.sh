#!/bin/sh

CURL="curl 'https://ewybory.msz.gov.pl/home/CommissionsList?countryId=__I__&typeOfVoting=Personally&_=__UNIX__' --compressed -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:126.0) Gecko/20100101 Firefox/126.0' -H 'Accept: text/html, */*; q=0.01' -H 'Accept-Language: pl,en-US;q=0.7,en;q=0.3' -H 'Accept-Encoding: gzip, deflate, br, zstd' -H 'Referer: https://ewybory.msz.gov.pl/zmien-miejsce-glosowania' -H 'X-Requested-With: XMLHttpRequest' -H 'Sec-Fetch-Dest: empty' -H 'Sec-Fetch-Mode: cors' -H 'Sec-Fetch-Site: same-origin' -H 'Connection: keep-alive' -H 'Cookie: visid_incap_3089413=6azk5S0dRBifsBUNdFiGZsblSWYAAAAAQ0IPAAAAAACAt6e0AVDzbIxeNQuVPuLdd99mx2u4ecTm; contrast=false; size=a; ApplicationGatewayAffinityCORS=41dc337ab3e312fffcedd30c9a8613f7; ApplicationGatewayAffinity=41dc337ab3e312fffcedd30c9a8613f7; nlbi_3089413=pzfvSH538lx9ubdd1tTMqwAAAACCOg9VrFU/6wor7KvHOBog; nlbi_3089413_2147483394=RuErE1s7zF8qcwEY1tTMqwAAAABN90qUqwPcVsrElRQowwOG; ASP.NET_SessionId=ri0p0ayzjykaw1hdyetbhnsz; incap_ses_7235_3089413=pAzGUVl4ZA+zGrrROOJnZCFEWGYAAAAA2tEEABOCftumqGEBqKP49g==; incap_ses_277_3089413=I5srJaVSlHE60fI/HRrYA/zvUGYAAAAApMxnOdKyC67tm+asa0TjtA==; incap_ses_7234_3089413=SXIFF/SPy0cl+kUqulRkZBl+T2YAAAAAgUATXTmNUfHGOA1TEfMe4g==; incap_ses_633_3089413=oz3AEB6Cd09a0vxjOt7ICCM7UmYAAAAADfPZoDvg+4cipBgouDs4tQ==; incap_ses_7236_3089413=xB9AdivnrzO/cZgmrm9rZBpMV2YAAAAAty9rx6efmek1IdIGDV4uUA==; BIGipServer~MC-WIP~POOL-eWybory-public=rd4o00000000000000000000ffff0a0a2a05o443' -H 'Priority: u=1' -H 'TE: trailers'"
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

