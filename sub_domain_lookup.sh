#!/bin/bash


lookup_domain() {

	echo "$sub_domains"|sed "s/$/\.$domain/g"|
	while read sub_domain; do
		dns_server=$(get_dns_server)
		echo $dns_server $sub_domain
	done|xargs -P 3 -n 2 host $2 $1|
		grep 'has address'|
		awk {'print $1, $4'}
}


get_dns_server() {
	# common public dns servers
	dns_servers="
		209.244.0.3
		209.244.0.4
		64.6.64.6
		64.6.65.6
		8.8.4.4
		8.8.8.8
		9.9.9.9 
		149.112.112.112
		208.67.222.222
	       	208.67.220.220
		216.146.35.35
		216.146.36.36
		37.235.1.174
		37.235.1.177";
	# select one at random
	echo "$dns_servers"|sort -R|tail -1
}

domain=$1

sub_domains=$(cat sub_domains_2.txt|sort -R|head -10)
sub_domain_count=$(echo "$sub_domains"|wc -l)

echo;echo "domain: $domain sub domain count: $sub_domain_count";echo

lookup_domain
