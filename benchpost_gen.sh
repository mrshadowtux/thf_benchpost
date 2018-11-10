#!/bin/bash
usage="Usage: ${0} user url"

user=$1
url=$2

if test -z $user ; then echo "user missing. $usage" ; exit 1; fi
if test -z $url ; then echo "url missing. $usage" ; exit 1 ; fi

function getfirstval
{
	value=$(
		curl $url 2>/dev/null \
		| grep -i "${*}" -A7 \
		| tail -1 \
		| cut -d ">" -f 2 \
		| cut -d "<" -f 1
	)
	echo $value
}


function getcores
{
	cpu_num=$(
		curl $url 2>/dev/null \
		| grep -i cores \
		| cut -d "," -f 1 \
		| cut -d ">" -f 2 \
		| cut -d " " -f 1
	)
	
	cpu_cores=$(
		curl $url 2>/dev/null \
		| grep -i cores \
		| cut -d "," -f 2 \
		| cut -d "<" -f 1 \
		| sed "s/Cores//"
	)
	
	cpu_threads=$(
		curl $url 2>/dev/null \
		| grep -i cores \
		| cut -d "," -f 3 \
		| cut -d "<" -f 1 \
		| sed "s/Threads//"
	)
	if test -z "$cpu_threads"
	then
		cpu_threads=$cpu_cores
	fi

	echo $cpu_num
	echo $cpu_cores
	echo $cpu_threads
}



cpu_num=$(getcores | head -1)
cpu_cores=$(getcores | head -2 | tail -1)
cpu_threads=$(getcores | tail -1)

if ! test -z "$cpu_num" ; then 
	cpu_corespecs="${cpu_num}/${cpu_cores}/${cpu_threads}"
else
	cpu_corespecs="${cpu_cores}/${cpu_threads}"
fi



cpu_clock=$(
	curl $url 2>/dev/null \
	| grep -i "base frequency" -A1 \
	| tail -1 \
	| cut -d ">" -f 2 \
	| cut -d "<" -f 1
)



scores=$(
	curl $url 2>/dev/null \
	| grep -i "<td class='score' rowspan='3'>" \
	| cut -d ">" -f 2 \
	| cut -d "<" -f 1
)

score_single=$(echo $scores | cut -d " " -f 1)
score_multi=$(echo $scores | cut -d " " -f 2)


cpu_name=$(getfirstval "Processor Information")
os=$(getfirstval "System Information")



echo "[tr]"
echo "	[td]@${user}[/td]"
echo "	[td]${score_multi}[/td]"
echo "	[td]${score_single}[/td]"
echo "	[td]${cpu_name}[/td]"
echo "	[td]${cpu_corespecs}[/td]"
echo "	[td]${cpu_clock}[/td]"
echo "	[td]${os}[/td]"
echo "	[td][URL='${url}']Link[/URL][/td]"
echo "[/tr]"
