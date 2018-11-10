#!/bin/bash
usage="Usage: $0 user listurl"

user=$1
listurl=$2

if test -z $user; then echo "user missing. $usage" ; exit 1 ; fi
if test -z $listurl ; then echo "listurl missing. $usage"; exit 1 ; fi


curl $listurl 2>/dev/null \
	| grep -i href \
	| grep -i "v4" \
	| grep -viE "top|results|tab" \
	| cut -d "'" -f 2 \
	| grep -vi compute \
	| while IFS= read -r benchurl ; do
		./benchpost_gen.sh "$user" "https://browser.geekbench.com${benchurl}" doit
	done
