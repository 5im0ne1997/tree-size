#!/bin/bash

TEMP_dir_all="/tmp/.dir_all.temp"
rm -f ${TEMP_dir_all} &>/dev/null
error_file="$HOME/ERROR_REPORT.txt"
rm -f ${error_file} &>/dev/null
report_file="$HOME/REPORT.txt"
rm -f ${report_file} &>/dev/null


if [ ${#} -eq 0 ] # If no options, search all directory
then
    dir=( '/' )
else
    continue=0
    for i in "${@}" # capture all options and arguments
    do
        if [ "${i}" == "-i" ]
        then
            continue=1 # continue=1 if option is -i and skip to the next argument
        elif [ ${continue} -eq 1 ]
        then
            dir+=( "${i}" ) # Add new argument in array
        else # if the first argument is'n -i print usage
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
    find ${i} -type d >> ${TEMP_dir_all} 2>>${error_file} # Search all directories in dir array
done

count=$(wc -l ${TEMP_dir_all} | cut -d" " -f 1) # Count all lines for the progress bar
if [ ${count} -lt 100 ]
then
    num_progress_barr=1 # If count is less than 100, I set this like 1 because we can't divide by 0
else
    num_progress_barr=$((${count} / 100)) # calculate 1% value
fi

for ((i=1; i<=${count}; i+=1))
do
    sed -i "${i}s@^@$(du -h -d 0 "$(sed -n "${i}{p;q}" ${TEMP_dir_all})" | cut -f 1);@" ${TEMP_dir_all} #for all line in ${TEMP_dir_all}, add at the beginning of all line the dimension
    echo $((${i} / ${num_progress_barr})) # calculate actual percent value
done 2>>${error_file} | whiptail --title "Calculating Result" --gauge "" 5 50 0 # print the progress bar

sort -hr ${TEMP_dir_all} > ${report_file} # sort directories by dimension
echo "The report file is generated in ${report_file}"
rm -f ${TEMP_dir_all}

exit 0