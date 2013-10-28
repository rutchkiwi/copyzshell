#!/bin/zsh
echo copyshell installed
copyshell() {
	if [[ ! ARGC -eq 1 ]] then
		echo "1 argument required, $# provided"
		exit 1
	elif [[ $1 = '-h' || $1 = '--help' ]] then
		echo "HELP MSG"
		exit 0
	else
		#set -e
		echo We will copy shell settings to $1
		echo Transfering $ZSH, .zshrc and .gitconfig.
		cd ~
		scp -r $ZSH .zshrc_new .gitconfig_new $1:/tmp
		zsh_base=${ZSH##*/}

		rc=$?
		#DO NOT TRANSFER WIERD GIT FILES!
		if [[ ! $rc = 1 && ! $rc = 0 ]] ; then
			echo "failing because error " $rc
			exit $rc
		fi

		echo We will now setup the shell via ssh.
		ssh -t $1 '
#/tmp!!!!!!!
		#move ZSH HOME!
		mv /tmp/'$zsh_base' '$ZSH'


		if [ -f .zshrc ]; then 
			mv .zshrc .zshrc_old; 
			echo "An existing .zshrc was found. It was moved to .zshrc_old"
		fi;

		if [ -f .gitconfig ]; then 
			mv .gitconfig .gitconfig_old; 
			echo "An existing .gitconfig was found. It was moved to .gitconfig_old"
		fi;

		mv /tmp/.zshrc .zshrc;
		mv /tmp/.gitconfig .gitconfig;


		chsh -s /bin/zsh'
		rm .zshrc_new .gitconfig_new
	fi
}


# Transfering .oh-my-zsh, .zshrc, .gitconfig and this script:
# :~/: No such file or directory
# We will now setup the shell via ssh.
# ssh: Could not resolve hostname if [ -f .zshrc ]; then
# 	mv .zshrc .zshrc_old;
# 	echo "An existing .zshrc was found. It was moved to: nodename nor servname provided, or not known
# /Users/viktor/oh-my-zsh-fork/plugins/copyshell/copyshell.plugin.zsh:22: parse error near `}'

#no gitconfig