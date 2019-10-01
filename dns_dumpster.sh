#!/bin/bash



get_dns() {
	domain=$1
	dig $domain any
}


get_cidr() {
	ips=$@
	for ip in $ips; do
		whois $ip|
		grep CIDR|
		awk {'print $1, $2, $3, $4'}|
		sed 's/CIDR://g'|
		sed 's/ //g'|
		tr "," "\n"
	done|sort|uniq
}


get_a_records() {
	echo "$dig_data"|
	grep '	A	'|
	awk {'print $5'}|sort|uniq

}


get_aaaa_records() {
	echo "$dig_data"|
	grep 'AAAA'|
	awk {'print $5'}|sort|uniq

}


get_mx_records() {
	echo "$dig_data"|
	grep 'MX'|
	awk {'print $6'}|
	while read record; do
		get_dns $record|
		awk {'print $5'}|
		grep -E "(\.|:)"|
		grep -E [0-9]|
		grep -E -v [a-z]
	done|sort|uniq
}


get_ns_records() {
	echo "$dig_data"|
	grep 'NS'|
	awk {'print $5'}|
	while read record; do
		get_dns $record|
		awk {'print $5'}|
		grep -E "(\.|:)"|
		grep -E [0-9]|
		grep -E -v [a-z]
	done|sort|uniq
}


get_asn() {
	ips=$@
	for ip in $ips; do
		whois -h whois.cymru.com " -v $ip"|
		cut -d "|" -f 1,3,7|
		grep [0-9]|
		sed 's/ //g'|
		grep -v -i error
	done|sort|uniq

}


main() {
	record_a=$(get_a_records)
	record_aaaa=$(get_aaaa_records)
	record_mx=$(get_mx_records)
	record_ns=$(get_ns_records)
	record_all=$(echo "$record_a $record_aaaa $record_mx $record_ns"|sort|uniq)
	net_range=$(get_cidr $record_all)
	asn=$(get_asn $net_range)
	bgp_range=$(echo "$asn"|cut -f2 -d "|")

	echo "# domain:"
	echo $domain
	echo
	echo "A Records:"
       	echo "$record_a"
	echo
	echo "AAAA Records:"
	echo "$record_aaaa"
	echo
	echo "MX Records:"
	echo "$record_mx"
	echo
	echo "NS Records:"
	echo "$record_ns"
	echo 
	echo "SWIP Networks:"
	echo "$net_range"
	echo
	echo "BGP Networks:"
        echo "$bgp_range"
	echo
	echo "ASNs:"
	echo "$asn"
}


[ $# -eq 0 ] && { echo "Usage: $0 domain_name.tld"; exit 1; }

domain=$1

# global dataset
dig_data=$(dig $domain any)

main
