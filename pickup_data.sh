#!/bin/sh

CURL="curl 'https://ewybory.msz.gov.pl/home/CommissionsList?countryId=__I__&typeOfVoting=Personally&_=__UNIX__' --compressed -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:125.0) Gecko/20100101 Firefox/125.0' -H 'Accept: */*' -H 'Accept-Language: pl,en-US;q=0.7,en;q=0.3' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' -H 'Referer: https://ewybory.msz.gov.pl/zmien-miejsce-glosowania' -H 'X-Requested-With: XMLHttpRequest' -H 'Origin: https://ewybory.msz.gov.pl' -H 'Sec-Fetch-Dest: empty' -H 'Sec-Fetch-Mode: cors' -H 'Sec-Fetch-Site: same-origin' -H 'Connection: keep-alive' -H 'Cookie: visid_incap_3089413=6azk5S0dRBifsBUNdFiGZsblSWYAAAAAQkIPAAAAAACAgm60AcI78aWbHn7n3mLrpAwMYciBuLrq; incap_ses_276_3089413=Aw32ZFcl70F6aTlInIzUAz0WSmYAAAAAPPAmlqBCZitELwOiZx6kuw==; ApplicationGatewayAffinityCORS=41dc337ab3e312fffcedd30c9a8613f7; ApplicationGatewayAffinity=41dc337ab3e312fffcedd30c9a8613f7; nlbi_3089413=pzfvSH538lx9ubdd1tTMqwAAAACCOg9VrFU/6wor7KvHOBog; contrast=false; size=a; nlbi_3089413_2147483394=p0x7fKbC40kJphMb1tTMqwAAAABa/OXARnA5Dxtq4xPjdcp/; ASP.NET_SessionId=ri0p0ayzjykaw1hdyetbhnsz; BIGipServer~MC-WIP~POOL-eWybory-public=rd4o00000000000000000000ffff0a0a2a15o443' --data-raw 'commissionId=0&gdprAgreement=on&citizenship=polskie&typeOfVotingFinall=Personally&typeOfVoting=Personally&country=5&lastName=&firstName=&middleName=&peselNumber=&route1IdentityType=Passport&route1IdentityNumber=&route2IdentityType=Passport&otherIdentityTypeName=&route2IdentityNumber=&identityExpireDate=&identityIssueDate=&identityIssuePlace=&abroadAddress=&abroadAddressCountry=&email=&phoneNumber='"
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

