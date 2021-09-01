#!/usr/bin/env bash

#set -o errexit   # abort on nonzero exitstatus
#set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

source vendor/bash_ini_parser/read_ini.sh

read_ini servers.ini

CURRENT_DIR=$(pwd)
DEFAULT_BACKUP_DIR="${CURRENT_DIR}/backups"

# user can provide backup directory, or we use current dir as default
BACKUP_DIR=${1:-${DEFAULT_BACKUP_DIR}}

delete_old_files() {
	# https://stackoverflow.com/a/47593062
	local DIRECTORY="${1}"
	local RETAIN_FILES="${2}"

	if [ ${RETAIN_FILES} -eq -1 ]; then
		return 0
	fi

	echo "This old files is being deleted :"
	find "${DIRECTORY}" -type f -printf '%T@\t%p\n' |
		sort -t $'\t' -g | 
		head -n -${RETAIN_FILES} | 
		cut -d $'\t' -f 2- |
		xargs --no-run-if-empty echo

	find "${DIRECTORY}" -type f -printf '%T@\t%p\n' |
		sort -t $'\t' -g | 
		head -n -${RETAIN_FILES} | 
		cut -d $'\t' -f 2- |
		xargs --no-run-if-empty rm

	return 0
}

sync_server_backups() {
	local SERVER_NAME=${1}
	local HOSTNAME_NAME="INI__${SERVER_NAME}__HostName"
	local USER_NAME="INI__${SERVER_NAME}__User"
	local PORT_NAME="INI__${SERVER_NAME}__Port"
	local LOCATION_NAME="INI__${SERVER_NAME}__Location"
	local RETAIN_FILES_NAME="INI__${SERVER_NAME}__RetainFiles"


	local HOSTNAME="${!HOSTNAME_NAME}"
	local USER="${!USER_NAME}"
	local PORT="${!PORT_NAME}"
	local LOCATION="${!LOCATION_NAME}"
	local RETAIN_FILES="${!RETAIN_FILES_NAME}"

	local THIS_SERVER_BACKUP_DIR="${BACKUP_DIR}/${SERVER_NAME}"

	[ ! -d "${THIS_SERVER_BACKUP_DIR}" ] && mkdir -p "${THIS_SERVER_BACKUP_DIR}"

	echo -e "\e[32;1mFetching backups from ${SERVER_NAME}.....\033[0m"

	rsync -azh --progress -e "ssh -p ${PORT}" "${USER}@${HOSTNAME}:${LOCATION}" "${THIS_SERVER_BACKUP_DIR}"

	echo -e "\e[32;1mDone\033[0m"

	delete_old_files ${THIS_SERVER_BACKUP_DIR} ${RETAIN_FILES}
}

for SERVER_NAME in ${INI__ALL_SECTIONS}; do

	sync_server_backups ${SERVER_NAME}

done

