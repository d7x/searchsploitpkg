## ************************ searchsploitpkg list script by D7X ************************
#
# Put your package list from linuxprivchecker.sh or dpkg -l in packages.txt 
# (or any other tool you use) 
# The script will take the value before the first '-' (dash) or provided separator so you may wish to modify
# the more important packages like the linux kernel to avoid a broad search:
# kernel-<STR> becomes -> 
# kernel 2.6- (spaces are accepted)
#
## ************************ searchsploitpkg list script by D7X ************************


#!/bin/bash

# added a separaor option so you can put your windows packages form tasklist command
S_STR="$3"

# parse arguments
if [ -z "$1" ] || [ "$#" -lt 3 ] || ( [ "$S_STR" != '-' ] && [ "$S_STR" != ' ' ] && [ "$S_STR" != '.' ] ); then
	echo "Usage: $0 <file with packages list> '[additional string in quotes]' [separator] [-t] [-v]"
	echo "Options:"
	echo -e "\t-t titles only"
	echo -e "\t-v verbose"
	echo -e "\t(could be used simultaneously) i.e. -t -v"
	printf "%s" "Example usage:
	(Linux)
	--------
	$0 packages.txt 'privilege linux' '-' -t
	$0 packages.txt 'privilege linux' '-' -v
	$0 packages.txt 'root linux' '-' -t -v
	
	(Windows)
	--------
	$0 packages.txt 'privilege' ' ' -t -v
	$0 packages.txt 'privilege' '.' -t -v (parses the appname before .exe)"
	
	printf "\n\n"
	printf "*** You may define some of the more important package versions in packages.txt like this: \nkernel 2.6- (or just substitute the first '-' with a space) ***"
	echo ""
	exit
fi

# verbose mode?
#verbose=0
#title=0
last_arg="${@: -1}"
last_bo_arg="${@:(-2):1}"
if [[ "$last_arg" == '-v' ]]; then
	verbose=1
fi
if [[ "$last_arg" == '-t' ]] || [[ "$last_bo_arg" == '-t' ]]; then
	title=1
fi
pkglist="$1"
searchstr="$2"
#str1="abcde qdw 123test qd qwdqw"
#str2="qdq"
#if [[ "$str1" == *" $str2 "* ]]; then
#	echo "contains"
#fi
#exit
RED='\033[1;31m'
NC='\e[0m' # No Color

result_buf=""
while read pkgname; do
	#echo $pkgname
	#if no separator is matched take just the first string
	if [ "$pkgname" != "$pkgname"*"$S_STR"* ]; then
		str=`echo $pkgname | cut -d " " -f1`
		#exit
	else str="$(echo $pkgname | cut -d "$S_STR" -f1)"
	fi

	#str=`echo $str | xargs echo -n` #trim string - deprecated
	#echo $str
	#continue;

	#check result
	if [ ! -z "$title" ]; then
	result_cmd="searchsploit --colour -t $str $searchstr"
	else
	result_cmd="searchsploit --colour $str $searchstr"
	fi
	
	result=`$result_cmd`
	#result=`searchsploit --colour $str $searchstr`
	#avoid repetitions
	if [ "$result_buf" == "$result_cmd" ]; then
		continue;
	fi
	
	result_buf="$result_cmd"
	if [ ! -z $verbose ]; then 
		#echo 'searchsploit --colour '$str $searchstr
		echo $result_cmd
	fi
	#if [[ ! "${result,,}" == *" ${str,,} "* ]]; then
	if [[ ! "${result,,}" == *"${str,,} "* ]]; then #white spaces removed as if there isn't whitespace at the beginning of the row the result is being skipped
		continue
	fi
	printf "\nResults for ${RED}%s${NC}\n" "$str $searchstr"
	printf "%s" "$result"
	printf "\n"
done < $pkglist

