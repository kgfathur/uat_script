#!/bin/bash
dir=$1
host=$2
if [ ! -z "$dir" ]; then
	echo -e "dir set to\t: $1"
	file=$(ls -d $1/rec-sar*)
	ndata=$(ls -d $1/rec-sar* | wc -l)
    
	echo ""
	# echo "processed files:"
	# echo "$file"
    echo "host:$host"
    echo "days:$ndata"
	echo ""
    echo "1) CPU_USAGE"
	echo 'Tanggal %usr %nice %sys %iowait %steal %irq %soft %guest %gnice %idle'

	for i in ${file[*]}
	do
		# get index
		n=$(grep -n 'Average.*all' $i | awk -F: '{print $1}')
		# echo "n: $n"
		# tanggal=$(cat $i | awk '{print $4 }' | head -n 1)
		# alter
		# tanggal=$(head -n 1 $i | awk '{print $4}')
		tanggal=$(awk 'NR==1{print $4}' $i)

		# cpu=$(grep Average $i | sed '2!d' | sed 's/.*all//')
		# alter
		cpu=$(awk NR==$n $i | sed 's/.*all//')
		echo $tanggal $cpu
	done
	echo "::"
    echo "2) RAM_USAGE"
	echo 'Tanggal kbmemfree kbmemused %memused kbbuffers kbcached kbcommit %commit kbactive kbinact kbdirty'
	for i in ${file[*]}
	do
		n=$(($(grep -n 'kbmemfree' $i | awk -F: '{print $1}')+1))
		# echo "n:$n"
		tanggal=$(awk 'NR==1{print $4}' $i)
		# alter
		# tanggal=$(head -n 1 $i | awk '{print $4}')
		# tanggal=$(awk 'NR==1{print $4}' $i)
		# mem=$(cat $i | sed '71!d' | sed 's/Average://')
		mem=$(sed -n ${n}p $i | sed 's/Average://')
		
		echo $tanggal $mem
	done
	echo "::"
    echo "3) SWAP_USAGE"
	echo 'Tanggal kbswpfree kbswpused %swpused kbswpcad %swpcad'
	for i in ${file[*]}
	do
		n=$(($(grep -n 'kbswpfree' $i | awk -F: '{print $1}')+1))
		
		tanggal=$(awk 'NR==1{print $4}' $i)

		swap=$(sed -n ${n}p $i | sed 's/Average://')
		# swap=$(cat $i | sed '73!d' | sed 's/Average://')
		echo $tanggal $swap
	done
	echo "::"

	nint=$(grep -E 'bond0|bond1|eno3' $(ls ${dir}/rec-sar* | awk 'NR==1{print}')| awk '{print NF}' | grep 9 | wc -l)
	# echo "interface: $nint"
	# nn=($(grep -n 'IFACE' rec-sar07 | awk -F: -e 'NR==1{printf "%s ",$1}' -e 'NR==2{print $1}'))
	# nn=$(grep -n 'IFACE' rec-sar07 | awk -F: '{print $1}')

	# n=$(grep -n -m1 'bond1' rec-sar07 | awk -F: '{print $1}')

	for iface in $(seq 1 $nint); do
		case $iface in
		1)
			inter='bond0'
			;;
		2)
			inter='bond1'
			;;
		3)
			inter='eno3'
			;;
		*)
			inter='bond0'
			;;
		esac

        echo "$(($iface+3))) NETWORK: $inter"
		echo 'Tanggal IFACE rxpck/s txpck/s rxkB/s txkB/s rxcmp/s txcmp/s rxmcst/s'

		for i in ${file[*]}
		do
			n=$(grep -n -m1 $inter $i | awk -F: '{print $1}')
			# echo "file: $i"
			tanggal=$(awk 'NR==1{print $4}' $i)
			# sed -n 
			# net=$(cat $i | sed '106!d' | sed 's/Average://')
			# net=$(cat $i | sed '106!d' | sed 's/Average://')
			net=$(sed -n ${n}p $i | sed 's/Average://')
			echo $tanggal $net
		done
		echo "::"
	done 


	# echo 'Tanggal IFACE rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s'
	# for i in ${file[*]}
	# do
	# 	tanggal=$(cat $i | awk '{print $4 }' | head -n 1)
	# 	net=$(cat $i | sed '105!d' | sed 's/Average://')
	# 	echo $tanggal $net
	# done
	# echo ""

	# echo 'Tanggal IFACE rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s'
	# for i in ${file[*]}
	# do
	# 	tanggal=$(cat $i | awk '{print $4 }' | head -n 1)
	# 	net=$(cat $i | sed '108!d' | sed 's/Average://')
	# 	echo $tanggal $net
	# done

	# echo ""
	# echo 'Tanggal IFACE rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s'
	# for i in ${file[*]}
	# do
	# 	tanggal=$(cat $i | awk '{print $4 }' | head -n 1)
	# 	net=$(cat $i | sed '114!d' | sed 's/Average://')
	# 	echo $tanggal $net
	# done
else
	echo "No directory set!!!"
fi