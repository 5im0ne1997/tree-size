#!/bin/bash

TEMP_dir_all="/tmp/.dir_all.temp"
rm -f ${TEMP_dir_all} &>/dev/null
error_file="$HOME/ERROR_REPORT.txt"
rm -f ${error_file} &>/dev/null
report_file="$HOME/REPORT.txt"
rm -f ${report_file} &>/dev/null


if [ ${#} -eq 0 ]
then
    dir=( $(ls / | grep -ve bin\
                    -ve boot\
                    -ve dev\
                    -ve etc\
                    -ve lib\
                    -ve mnt\
                    -ve proc\
                    -ve run\
                    -ve sys\
                    -ve usr | sed "s/^/\//") )
else
    continue=0
    for i in "${@}"
    do
        if [ "${i}" == "-i" ]
        then
            continue=1
        elif [ ${continue} -eq 1 ]
        then
            dir+=( "${i}" )
        else
            echo "USAGE: sudo ${0} [OPTION] [DIRECTORY]"
            echo "Without OPTION the default directory is /"
            echo "OPTION"
            echo "-i    Include directory"
            echo "EXAMPLE: sudo ./treesize.sh -i /data /var/log /tmp"
            exit 1
        fi
    done
fi

for i in ${dir[@]}
do 
    find ${i} -type d >> ${TEMP_dir_all} 2>>${error_file}
done

count=$(wc -l ${TEMP_dir_all} | cut -d" " -f 1)
if [ ${count} -lt 100 ]
then
    num_progress_barr=1
else
    num_progress_barr=$((${count} / 100))
fi

for ((i=1; i<=${count}; i+=1))
do
    sed -i "${i}s@^@$(du -h -d 0 "$(sed -n "${i}{p;q}" ${TEMP_dir_all})" | cut -f 1);@" ${TEMP_dir_all}
    echo $((${i} / ${num_progress_barr}))
done 2>>${error_file} | whiptail --title "Calculating Result" --gauge "" 5 50 0

sort -hr ${TEMP_dir_all} > ${report_file}
echo "The report file is generated in ${report_file}"
rm -f ${TEMP_dir_all}

exit 0