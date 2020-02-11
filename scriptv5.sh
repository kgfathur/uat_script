#!/bin/bash
# init_dir="$HOME/garap/uat/"
init_dir="$(pwd)/"
file_fps=$(zenity --file-selection --multiple --separator=" " --file-filter='Archive (tar.xz) | *.tar.xz' --title='Select a File(s)' --filename=$init_dir/data/)

echo "file:$file_fps"
awal=true
replace=false
verbose=false

case $1 in
    '-f')
        replace=true
        ;;
    '-v')
        verbose=true
        ;;
    *)
        ;;
esac

# echo "replace: $replace"

if [ -z "$file_fps" ]; then
    answer=$(zenity --question --title="File Belum Dipilih!" --text="Yakin tidak jadi nih?" --ok-label="iya" --cancel-label="nggak, deh")
    echo "exit:$answer:$?"
else

    for file_fp in $file_fps ; do
        echo "file selected: $file_fp"
        
        file_name=$(basename "$file_fp")
        host=$(echo $file_name | awk -F- '{print $2}')

        echo -e "host\t\t: $host"
        out_dir="${init_dir}output/$host"

        dir=${file_name::-7}/var/log/sa/sar*

        echo -e "File FP\t\t: $file_fp"
        echo -e "File Name\t: $file_name"
        echo -e "Out Dir\t\t: $out_dir"
        echo -e "File Extracted\t: $dir"

        echo "awal: $awal"
        if $awal; then
            echo "$out_dir $host" > ${init_dir}log
            awal=false
        else
            echo "$out_dir $host" >> ${init_dir}log
        fi
        echo "awal: $awal"
        #  ++++++++++++++++++++++++++++++++++++++++++++++++++++ OKE
        # if [ ! -d "$out_dir" ]; then
        #     mkdir -p $out_dir
        #     echo "Creating \"$out_dir\" directory"
        # fi
        if [ $replace == true ]; then
            extracting=1;
            echo "replacing... $replace"
        else
            echo "replacing!!! $replace"
            if [ -d "$out_dir" ]; then
                zenity --question --title="Warning!" --text="Folder untuk $out_dir sudah ada. Tetap extract ulang?"
                if [ $? == 1 ]; then
                    echo "extract canceled"
                    extracting=0;
                else
                    # answer is yes
                    echo "extracting..."
                    extracting=1;
                fi
            else
                echo "extracting..."
                extracting=1;
            fi
        fi

        if [ "$extracting" == 1 ]; then
            mkdir -p $out_dir

            # dir=$(tar -tf /home/probation/garap/uat/sosreport-LXTSPRID103-2019-11-18-dpisyhf.tar.xz | grep 'var/log/sa/' | head -n 1)
            # dir=$(tar -tf $file_fp | head -n 1)
            # dir=${dir}var/log/sa/sar*

            echo -e "Extracted to\t: ${out_dir}"

            # tar -C ${init_dir}${out_dir} --strip-components=4 -xJvf $file_fp $dir
            tar -C ${out_dir} --strip-components=4 -xJf $file_fp $dir

        fi
        log_file=$(ls ${out_dir}/sar*)
        
        # echo "$log_file" > ${out_dir}/log

        # echo "file is:"
        # echo $log_file
        for file in $log_file; do
            # echo "$(basename "$file")"

            rec_file=$out_dir/log_$(basename "$file")
            grep -Ei 'average|CPU|proc/s|pswpin/s|pgpgin/s|bwrtn/s|frmpg/s|kbmemfree|kbswpfree|kbhugfree|dentunusd|runq-sz|TTY|rd_sec/s|IFACE|getatt/s|sgetatt/s|totsck' $file > $rec_file
            strips=$(grep -n 'CPU' $rec_file | wc -l)
            strips=$(( strips-1 ))
            sed -i "2,${strips-1}d" $rec_file
        
        done

        echo "processing..."
        if [ "$extracting" == 1 ]; then
            bash $init_dir/average.sh $out_dir $host > $out_dir/output.xlsx
            sed -i '1,2d' $out_dir/output.xlsx
        fi

        echo "sorting..."

        days=$(grep 'days:' $out_dir/output.xlsx | sed 's/days://')
        echo "host: $host"
        echo "days: $days"
        echo ""
        
        npar=$(grep -E '1)|2)|3)|4)|5)|6)' $out_dir/output.xlsx | wc -l)
        # npar=4

        echo "1) CPU USAGE"  | tee ${out_dir}/out_sorted.xlsx
        echo 'Tanggal %usr %nice %sys %iowait %steal %irq %soft %guest %gnice %idle' | tee -a ${out_dir}/out_sorted.xlsx
        awk '/^1) /,/^::$/' $out_dir/output.xlsx | sed -n "3,$((days+2))p" | sort -k 1 | tee -a ${out_dir}/out_sorted.xlsx
        echo "::" | tee -a ${out_dir}/out_sorted.xlsx

        echo "$host cpu - -" > ${out_dir}/plot_cpu
        echo "Tanggal %usr %sys %idle" >> ${out_dir}/plot_cpu
        awk '/^1) /,/^::$/' $out_dir/output.xlsx | sed -n "3,$((days+2))p" | sort -k 1 | awk '{printf "%s %s %s %s\n", $1, $2, $4, $11}' >> ${out_dir}/plot_cpu

        echo "2) RAM USAGE" | tee -a ${out_dir}/out_sorted.xlsx
        echo "Tanggal kbmemfree kbmemused %memused kbbuffers kbcached kbcommit %commit kbactive kbinact kbdirty"
        awk '/^2) /,/^::$/' $out_dir/output.xlsx | sed -n "3,$((days+2))p" | sort -k 1 | tee -a ${out_dir}/out_sorted.xlsx
        echo "::" | tee -a ${out_dir}/out_sorted.xlsx

        echo "$host ram - -" > ${out_dir}/plot_ram
        echo "Tanggal kbmemused %memused kbcached" >> ${out_dir}/plot_ram
        awk '/^2) /,/^::$/' $out_dir/output.xlsx | sed -n "3,$((days+2))p" | sort -k 1 | awk '{printf "%s %s %s %s\n", $1, $3, $4, $6}' >> ${out_dir}/plot_ram

        echo "3) SWAP USAGE" | tee -a ${out_dir}/out_sorted.xlsx
        echo 'Tanggal kbswpfree kbswpused %swpused kbswpcad %swpcad' | tee -a ${out_dir}/out_sorted.xlsx
        awk '/^3) /,/^::$/' $out_dir/output.xlsx | sed -n "3,$((days+2))p" | sort -k 1 | tee -a ${out_dir}/out_sorted.xlsx
        echo "::" | tee -a ${out_dir}/out_sorted.xlsx

        echo "$host swap" > ${out_dir}/plot_swp
        echo "Tanggal kbswpused" >> ${out_dir}/plot_swp
        awk '/^3) /,/^::$/' $out_dir/output.xlsx | sed -n "3,$((days+2))p" | sort -k 1 | awk '{printf "%s %s\n", $1, $3}' >> ${out_dir}/plot_swp


        for idx in $(seq 4 $npar); do
            # echo "npar = $idx"
            grep "^$idx) " $out_dir/output.xlsx | tee -a ${out_dir}/out_sorted.xlsx
            echo 'Tanggal IFACE rxpck/s txpck/s rxkB/s txkB/s rxcmp/s txcmp/s rxmcst/s' | tee -a ${out_dir}/out_sorted.xlsx
            awk "/^$idx) /,/^::$/" $out_dir/output.xlsx | sed -n "3,$((days+2))p" | sort -k 1 | tee -a ${out_dir}/out_sorted.xlsx
            echo "::" | tee -a ${out_dir}/out_sorted.xlsx

            echo "$host net $(awk "/^$idx) /,/^::$/" ${out_dir}/out_sorted.xlsx | awk 'NR==1 {print $3}') -" > ${out_dir}/plot_net$((idx-3))
            echo 'Tanggal IFACE rxkB/s txkB/s' >> ${out_dir}/plot_net$((idx-3))
            awk "/^$idx) /,/^::$/" $out_dir/output.xlsx | sed -n "3,$((days+2))p" | sort -k 1 | awk '{printf "%s %s %s %s\n", $1, $2, $5, $6}' >> ${out_dir}/plot_net$((idx-3))
        done

        ls $out_dir/plot_* > $out_dir/plots
        echo "plotting..."
        # echo "$plots"

    done
    # Time to plot
    python ${init_dir}graph_oke.py ${init_dir}log

fi

# # # # # # # # CORETAN
# sed -n '/totsck/,/Average/p' sar01 | grep -i average
# awk '/StartPattern/,/EndPattern/'
# grep -Ei 'average|CPU|proc/s|pswpin/s|pgpgin/s|bwrtn/s|frmpg/s|kbmemfree|kbswpfree|kbhugfree|dentunusd|runq-sz|TTY|rd_sec/s|IFACE|getatt/s|sgetatt/s|totsck'
# grep -n CPU rec11 | wc -l