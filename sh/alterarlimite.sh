#!/bin/bash
tput setaf 7 ; tput setab 4 ; tput bold ; printf '%20s%s\n' "   Change concurrent connection limit   " ; tput sgr0
database="/root/usuarios.db"
if [ ! -f "$database" ]; then
	tput setaf 7 ; tput setab 1 ; tput bold ; echo "" ; echo "Archive $database not found" ; echo "" ; tput sgr0
	exit 1
else
	tput setaf 3 ; tput bold ; echo ""; echo "LIST OF USERS AND THEIR LIMITS:" ; tput sgr0
	echo ""
	_userT=$(awk -F: '$3>=1000 {print $1}' /etc/passwd | grep -v nobody)
	i=0
	unset _userPass
	while read _user; do
		i=$(expr $i + 1)
		_oP=$i
		[[ $i == [1-9] ]] && i=0$i && oP+=" 0$i"
		if [[ "$(grep -wc "$_user" $database)" != "0" ]]; then
			limit=$(grep -w "$_user" $database |cut -d' ' -f2)
		else
			limit='1'
		fi
		l_user=$(echo -e "\033[1;31m[\033[1;36m$i\033[1;31m] \033[1;37m- \033[1;32m$_user\033[0m")
        lim=$(echo -e "\033[1;33mLimite\033[1;37m: $limit")
        printf '%-65s%s\n' "$l_user" "$lim"
		_userPass+="\n${_oP}:${_user}"
	done <<< "${_userT}"
	echo ""
	num_user=$(awk -F: '$3>=1000 {print $1}' /etc/passwd | grep -v nobody | wc -l)
	echo -ne "\033[1;32mEnter or select a user \033[1;33m[\033[1;36m1\033[1;31m-\033[1;36m$num_user\033[1;33m]\033[1;37m: " ; read option
	usuario=$(echo -e "${_userPass}" | grep -E "\b$option\b" | cut -d: -f2)
    if [[ -z $option ]]; then
        tput setaf 7 ; tput setab 1 ; tput bold ; echo "" ; echo "User empty or nonexistent" ; echo "" ; tput sgr0
		exit
	elif [[ -z $usuario ]]; then
		tput setaf 7 ; tput setab 1 ; tput bold ; echo "" ; echo "User empty or nonexistent" ; echo "" ; tput sgr0
		exit 1
	else
		if cat /etc/passwd |grep -w $usuario > /dev/null; then
			echo -ne "\n\033[1;32mNew user limit \033[1;33m$usuario\033[1;37m: "; read sshnum
			if [[ -z $sshnum ]]
			then
				tput setaf 7 ; tput setab 1 ; tput bold ; echo "" ; echo "You entered an invalid number!" ; echo "" ; tput sgr0
				exit 1
			else
				if (echo $sshnum | egrep [^0-9] &> /dev/null)
				then
					tput setaf 7 ; tput setab 1 ; tput bold ; echo "" ; echo "You entered an invalid number!" ; echo "" ; tput sgr0
					exit 1
				else
					if [[ $sshnum -lt 1 ]]
					then
						tput setaf 7 ; tput setab 1 ; tput bold ; echo "" ; echo "You must enter a number greater than zero!" ; echo "" ; tput sgr0
						exit 1
					else
						grep -v ^$usuario[[:space:]] /root/usuarios.db > /tmp/a
						sleep 1
						mv /tmp/a /root/usuarios.db
						echo $usuario $sshnum >> /root/usuarios.db
						tput setaf 7 ; tput setab 4 ; tput bold ; echo "" ; echo "Limit applied to user $usuario was $sshnum " ; tput sgr0
						sleep 2
						exit
					fi
				fi
			fi			
		else
			tput setaf 7 ; tput setab 1 ; tput bold ; echo "" ; echo "The user $usuario was not found" ; echo "" ; tput sgr0
			exit 1
		fi
	fi
fi
