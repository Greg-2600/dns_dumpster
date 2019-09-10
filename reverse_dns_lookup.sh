#!/bin/bash


check_prips() {

	service='prips'
	service_path=$(which prips)

	if [ -z $service_path ]; then
		echo 'Please install prips'
		echo 'sudo apt install -y prips'
	fi
}


expand_networks() {
	cidr_networks=$@
	for network in $cidr_networks; do
		prips $network|sort -R
	done
}


lookup_ip() {
	ip=$1
	domain=$(host $ip 8.8.8.8)
	echo "$ip $domain"|
	grep -v 'not found'|
	grep 'ointer'|
	awk {'print $5'}|
	sed 's/.$//g'
}


main() {
	check_prips
	cores=$(grep proces /proc/cpuinfo|wc -l)
	ip_list=$(expand_networks $cidr_networks)

	echo "$ip_list"|
	xargs -P $cores -n 1 -I {} bash -c 'lookup_ip "$1"' _ {}
}


cidr_networks=$@
export -f lookup_ip

main
