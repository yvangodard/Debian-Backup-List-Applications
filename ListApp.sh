#! /bin/bash

#------------------------------------------#
#                ListApp                   #
#------------------------------------------#
#                                          #
#  Backup list of applications installed   #
#   	        on Debian                  #
#                                          #
#              Yvan Godard                 #
#          godardyvan@gmail.com            #
#                                          #
#       Version 0.1 -- may, 30 2014        #
#             Under Licence                #
#     Creative Commons 4.0 BY NC SA        #
#                                          #
#          http://goo.gl/lriKvn            #
#                                          #
#------------------------------------------#

# Variables initialisation
VERSION="ListApp v0.1 - 2014, Yvan Godard [godardyvan@gmail.com]"
help="no"
SCRIPT_DIR=$(dirname $0)
SCRIPT_NAME=$(basename $0)
BACKUP_LIST_FOLDER="/var/ListApp"
EMAIL_REPORT="nomail"
EMAIL_LEVEL=0
LOG="/var/log/ListApp.log"
LOG_ACTIVE=0
LOG_TEMP=$(mktemp /tmp/ListApp.XXXXX)
HOWMANYDAILY_DEFAULT=14
HOWMANYDAILY=$(echo ${HOWMANYDAILY_DEFAULT})
HOWMANYWEEKLY_DEFAULT=8
HOWMANYWEEKLY=$(echo ${HOWMANYWEEKLY_DEFAULT})
DATANAME="backup-$(date +%d.%m.%y@%Hh%M).apps.list"
INPUT_FILE=${BACKUP_LIST_FOLDER}/last.apps.list
EMAIL_ADDRESS=""

help () {
	echo -e "$VERSION\n"
	echo -e "This tool is designed to backup and restore your programs on Debian."
	echo -e "\nDisclamer:"
	echo -e "This tool is provide without any support and guarantee."
	echo -e "\nSynopsis:"
	echo -e "./$SCRIPT_NAME [-h] | -m <mode>" 
	echo -e "                  [-l <list of programs folder>] [-j <log file>]"
	echo -e "                  [-d <number of daily list to keep>] [-w <number of weekly list to keep>]"
	echo -e "                  [-i <input list of apps to restore>]"
	echo -e "                  [-e <email report option>] [-E <email address>]"
	echo -e "\n\t-h:                             prints this help then exit"
	echo -e "\nMandatory options:"
	echo -e "\t-m <mode>:                           the mode to use, must be 'backup' or 'restore'"
	echo -e "\nOptional options:"
	echo -e "\t-l <list of programs folder>:        path to write backup files (i.e.: '/home/backups/apps', default: '${BACKUP_LIST_FOLDER}')"
	echo -e "\t-j <log file>:                       enables logging instead of standard output. Specify an argument for the full path to the log file"
	echo -e "\t                                     (i.e.: '${LOG}') or use 'default' (${LOG})"
	echo -e "\t-d <number of daily lists to keep>:  number of daily backup lists of applications to keep (default: '${HOWMANYDAILY}'),"
	echo -e "\t                                     this parameter is only to use with '-m backup'."
	echo -e "\t-w <number of weekly lists to keep>: number of weekly backup lists of applications to keep (default: '${HOWMANYWEEKLY}'),"
	echo -e "\t                                     this parameter is only to use with '-m backup'."
	echo -e "\t-i <input list of apps to restore>:  full path of list of applications you want to restore (default: '${INPUT_FILE}'),"
	echo -e "\t                                     this parameter is only to use with '-m restore'."
	echo -e "\t-e <email report option>:            settings for sending a report by email, must be 'onerror', 'forcemail' or 'nomail' (default: '${EMAIL_REPORT}')"
	echo -e "\t-E <email address>:                  email address to send the report (must be filled if '-e forcemail' or '-e onerror' options is used)"
	exit 0
}

error () {
	echo -e "\n*** Error ***"
	echo -e ${1}
	echo -e "\n"${VERSION}
	alldone 1
}

alldone () {
	# Redirect standard outpout
	exec 1>&6 6>&-
	# Logging if needed 
	[ ${LOG_ACTIVE} -eq 1 ] && cat ${LOG_TEMP} >> ${LOG}
	# Print current log to standard outpout
	[ ${LOG_ACTIVE} -ne 1 ] && cat ${LOG_TEMP}
	[ ${EMAIL_LEVEL} -ne 0 ] && [ ${1} -ne 0 ] && cat ${LOG_TEMP} | mail -s "[ERROR : ${SCRIPT_NAME}] on $(hostname)" ${EMAIL_ADDRESS}
	[ ${EMAIL_LEVEL} -eq 2 ] && [ ${1} -eq 0 ] && cat ${LOG_TEMP} | mail -s "[OK : ${SCRIPT_NAME}] on $(hostname)" ${EMAIL_ADDRESS}
	rm ${LOG_TEMP}
	exit ${1}
}

optsCount=0

while getopts "hm:l:j:d:w:i:e:E:" OPTION
do
	case "$OPTION" in
		h)	help="yes"
						;;
		m)	MODE=${OPTARG}
			let optsCount=$optsCount+1
						;;
		l)	BACKUP_LIST_FOLDER="${OPTARG%/}"
						;;
        e)	EMAIL_REPORT=${OPTARG}
                        ;;                             
        E)	EMAIL_ADDRESS=${OPTARG}
                        ;;
        j)	[ ${OPTARG} != "default" ] && LOG=${OPTARG}
			LOG_ACTIVE=1
                        ;;           
		i)	INPUT_FILE=${OPTARG}
                        ;;
        w)	HOWMANYWEEKLY=${OPTARG}
                        ;;
		d)	HOWMANYDAILY=${OPTARG}
                        ;;
	esac
done

if [[ ${optsCount} != "1" ]]
	then
	help
	alldone 1
fi

[[ ${help} = "yes" ]] && help

# Redirect standard outpout to temp file
exec 6>&1
exec >> ${LOG_TEMP}

# Start temp log file
echo -e "\n****************************** `date` ******************************\n"
echo -e "$0 started on $(hostname)\n"

# Test of sending email parameter and check the consistency of the parameter email address
if [[ ${EMAIL_REPORT} = "forcemail" ]]
	then
	EMAIL_LEVEL=2
	if [[ -z $EMAIL_ADDRESS ]]
		then
		echo -e "You use option '-e ${EMAIL_REPORT}' but you have not entered any email info.\n\t-> We continue the process without sending email."
		EMAIL_LEVEL=0
	else
		echo "${EMAIL_ADDRESS}" | grep '^[a-zA-Z0-9._-]*@[a-zA-Z0-9._-]*\.[a-zA-Z0-9._-]*$' > /dev/null 2>&1
		if [ $? -ne 0 ]
			then
    		echo -e "This address '${EMAIL_ADDRESS}' does not seem valid.\n\t-> We continue the process without sending email."
    		EMAIL_LEVEL=0
    	fi
    fi
elif [[ ${EMAIL_REPORT} = "onerror" ]]
	then
	EMAIL_LEVEL=1
	if [[ -z $EMAIL_ADDRESS ]]
		then
		echo -e "You use option '-e ${EMAIL_REPORT}' but you have not entered any email info.\n\t-> We continue the process without sending email."
		EMAIL_LEVEL=0
	else
		echo "${EMAIL_ADDRESS}" | grep '^[a-zA-Z0-9._-]*@[a-zA-Z0-9._-]*\.[a-zA-Z0-9._-]*$' > /dev/null 2>&1
		if [ $? -ne 0 ]
			then	
    		echo -e "This address '${EMAIL_ADDRESS}' does not seem valid.\n\t-> We continue the process without sending email."
    		EMAIL_LEVEL=0
    	fi
    fi
elif [[ ${EMAIL_REPORT} != "nomail" ]]
	then
	echo -e "\nOption '-e ${EMAIL_REPORT}' is not valid (must be: 'onerror', 'forcemail' or 'nomail').\n\t-> We continue the process without sending email."
	EMAIL_LEVEL=0
elif [[ ${EMAIL_REPORT} = "nomail" ]]
	then
	EMAIL_LEVEL=0
fi

# Test log file
if [[ ${LOG_ACTIVE} == "1" ]]
	then
	if [[ ! -f ${LOG} ]]
		then
		touch ${LOG}
		[ $? -ne 0 ] && error "Error when trying to create log file '${LOG}'"
	fi
fi

# Test option -m (mode)
[[ ${MODE} != "backup" ]] && [[ ${MODE} != "restore" ]] && error "Parameter '-m ${MODE}' is not correct.\n-m must be 'backup' or 'restore'"

# Test options HOWMANYDAILY & HOWMANYWEEKLY
if [[ ! -z "`echo ${HOWMANYDAILY} | sed s/[0-9]*//`" ]]
	then
	echo -e "Option '-d ${HOWMANYDAILY}' is not valid, should be an integer.\n\t-> We continue the process without standard option '-d ${HOWMANYDAILY_DEFAULT}'."
	HOWMANYDAILY=$(echo ${HOWMANYDAILY_DEFAULT})
fi
if [[ ! -z "`echo ${HOWMANYWEEKLY} | sed s/[0-9]*//`" ]]
	then
	echo -e "Option '-w ${HOWMANYWEEKLY}' is not valid, should be an integer.\n\t-> We continue the process without standard option '-d ${HOWMANYWEEKLY_DEFAULT}'."
	HOWMANYWEEKLY=$(echo ${HOWMANYWEEKLY_DEFAULT})
fi

# Test on location
if [[ ${MODE} = "backup" ]]
	then
	if [[ ! -d ${BACKUP_LIST_FOLDER} ]]
		then
		echo -e "Creating backup path '${BACKUP_LIST_FOLDER}'..."
		mkdir -p ${BACKUP_LIST_FOLDER}
		if [ $? -ne 0 ] 
			then
			error "Impossible to create folder '${BACKUP_LIST_FOLDER}'.\nPlease create it or verify this path and re-launch this tool."
		else
			echo -e "\t-> Path ${BACKUP_LIST_FOLDER} successfully created."
		fi
	fi
elif [[ ${MODE} = "restore" ]]
	then
	[[ ! -f ${INPUT_FILE} ]] && error "Impossible to read ${INPUT_FILE} as source.\nPlease verify this path and re-launch this tool."
fi

# Backup loop
if [[ ${MODE} = "backup" ]]
	then
	if [ "$( date +%w )" == "0" ]
		then
        [ ! -d ${BACKUP_LIST_FOLDER}/weekly ] && mkdir -p ${BACKUP_LIST_FOLDER}/weekly
        DATADIR=${BACKUP_LIST_FOLDER}/weekly
        KEEP_NUMBER=${HOWMANYWEEKLY}
        echo "Weekly backup:"
        echo -e "\t-> ${KEEP_NUMBER} days of backup list files will be stored."
	else
        [ ! -d ${BACKUP_LIST_FOLDER}/daily ] && mkdir -p ${BACKUP_LIST_FOLDER}/daily
        DATADIR=${BACKUP_LIST_FOLDER}/daily
        KEEP_NUMBER=${HOWMANYDAILY}
        echo "Daily backup:"
        echo -e "\t-> ${KEEP_NUMBER} days of backup list files will be stored."
    fi
    # Creating application list
    echo "Creating backup ${DATADIR}/${DATANAME}..."
    dpkg --get-selections > ${DATADIR}/${DATANAME}
    [ $? -ne 0 ] && error "Error when trying to create backup list '${DATADIR}/${DATANAME}'."
    [ -f ${BACKUP_LIST_FOLDER}/last.apps.list ] &&  rm ${BACKUP_LIST_FOLDER}/last.apps.list
    ln -s ${DATADIR}/${DATANAME} ${BACKUP_LIST_FOLDER}/last.apps.list
    [ -f ${DATADIR}/last.apps.list ] &&  rm ${DATADIR}/last.apps.list
    ln -s ${DATADIR}/${DATANAME} ${DATADIR}/last.apps.list
    # Delete old backup files
    echo "Deleting old backups if needed..." 
    find ${DATADIR} -name "*.apps.list" -mtime +${KEEP_NUMBER} -print -exec rm {} \;
    [ $? -ne 0 ] && error "Error when trying to delete old backup files."
fi

# Restore loop
if [[ ${MODE} = "restore" ]]
	then
	[[ `whoami` != 'root' ]] && error "You need to run this tool as root to be able to use '-m restore' option. Please use SUDO."
	echo "Restore:"
	cat ${INPUT_FILE}
	sudo dpkg --set-selections < ${INPUT_FILE}
	[ $? -ne 0 ] && error "Error when trying to use command 'sudo dpkg --set-selections < ${INPUT_FILE}'."
	sudo apt-get dselect-upgrade
fi

echo -e "\nAll the process seems to be OK!"
alldone 0