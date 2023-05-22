#!/bin/bash

TEMP_dir_all="/tmp/.dir_all.temp"
rm -f ${TEMP_dir_all} &>/dev/null
error_file="$HOME/ERROR_REPORT.txt"
rm -f ${error_file} &>/dev/null
report_file="$HOME/REPORT.txt"
rm -f ${report_file} &>/dev/null

continue=0
for i in "${@}" # capture all options and arguments
do
    if [ "${i}" == "-i" ]
    then
        continue=1 # continue=1 if option is -i and skip to the next argument
    elif [ "${i}" == "-d" ]
    then
        continue=3 # continue=3 if option is -d and skip to the next argument
    elif [ ${continue} -eq 1 ]
    then
        dir+=( "${i}" ) # Add new argument in array
    elif [ ${continue} -eq 3 ] && [ "${i}" -ge 0 ]
    then
        max_depth="-maxdepth ${i}" # modify find depth
        continue=0
    else # if the first argument is'n -i print usage
        echo "USAGE: sudo ${0} [OPTION] [DIRECTORY]"
        echo "OPTION"
        echo "-i    Include directory, default /"
        echo "-d    Depth"
        echo "EXAMPLE: sudo ./treesize.sh -i /data /var/log /tmp -d 2"
        exit 1
    fi
done

if [ ${#dir[0]} -eq 0 ]
then
    dir=( '/' )
fi


for i in ${dir[@]}
do 
    dir_all=( $(find ${i} ${max_depth} -type d -exec ls -d {} \; 2>>${error_file}) ) # Search all directories in dir array
done

count=$(echo ${#dir_all[@]}) # Count all lines for the progress bar
if [ ${count} -lt 100 ]
then
    num_progress_barr=1 # If count is less than 100, I set this like 1 because we can't divide by 0
else
    num_progress_barr=$((${count} / 100)) # calculate 1% value
fi

for ((i=0; i<=((${count} - 1)); i+=1))
do
    echo ${dir_all[$i]} |  sed "s@^@$(du -h -d 0 ${dir_all[$i]} | cut -f 1);@" >> ${TEMP_dir_all} #for all line in ${TEMP_dir_all}, add at the beginning of all line the dimension
    echo $((${i} / ${num_progress_barr})) # calculate actual percent value
done 2>>${error_file} | whiptail --title "Calculating Result" --gauge "" 5 50 0 # print the progress bar

sort -hr ${TEMP_dir_all} > ${report_file} # sort directories by dimension
sed -i "1iDimension;Path" ${report_file}
echo "The report file is generated in ${report_file}"
rm -f ${TEMP_dir_all}

exit 0