#!/bin/zsh
if [[ ! ARGC -eq 1 ]] then
	echo "1 argument required, $# provided"
	exit 1
elif [[ $1 = '-h' || $1 = '--help' ]] then
	echo "HELP MSG"
	exit 0 
else
	echo "OK LETS GO"
	zmodload zsh/regex
	#check that the ZSH path is not wierd
	if [[ ! $ZSH -regex-match ^$HOME/(.+) ]] then
		echo "Your ZSH folder "$ZSH" doesn't seem to be in your home folder. Cowardly quitting"
		exit 1
	fi
	
	echo "2"
	zsh_folder=${ZSH#$HOME/} # could be in multiple subfolders relative to $HOME TODO TEST!
	zsh_base=${ZSH##*/}
	echo $zsh_folder
	#mkdir -p

	cd ~
	set -e
	echo We will copy shell settings to $1
	echo Transfering $ZSH, .zshrc and .gitconfig.
	#doing this in a batch so we don't have to ask for password so much
	scp -r $ZSH .zshrc .gitconfig $1:/tmp

	# rc=$?
	#DO NOT TRANSFER WIERD GIT FILES!
	# if [[ ! $rc = 1 && ! $rc = 0 ]] ; then
	# 	echo "failing because error " $rc
	# 	exit $rc
	# fi

	datestr=$(date "+%Y-%m-%d-%H:%M:%S")
	echo File transfer complete. We will now setup the shell via ssh.

	#todo: take into account usernames!!
	ssh -t $1 '
	cd ~
	
	#check for pre-existing zsh folder!
	if [[ -f $zsh_folder ]] then
		echo Folder aldready exists!
		#do stuff
	fi
	mkdir -p '$zsh_folder'
	echo mv /tmp/'$zsh_base'/* '$zsh_folder'
	mv /tmp/'$zsh_base'/* '$zsh_folder'


	if [ -f .zshrc ]; then 
		mv .zshrc .zshrc_'$datestr' 
		echo "An existing .zshrc was found. It was moved to .zshrc_'datestr'"
	fi

	if [ -f .gitconfig ]; then 
		mv .gitconfig .gitconfig_'$datestr'
		echo "An existing .gitconfig was found. It was moved to .gitconfig_'datestr'"
	fi

	mv /tmp/.zshrc .zshrc
	mv /tmp/.gitconfig .gitconfig


	chsh -s /bin/zsh'
	rm .zshrc_new .gitconfig_new
fi

# Transfering .oh-my-zsh, .zshrc, .gitconfig and this script:
# :~/: No such file or directory
# We will now setup the shell via ssh.
# ssh: Could not resolve hostname if [ -f .zshrc ]; then
# 	mv .zshrc .zshrc_old;
# 	echo "An existing .zshrc was found. It was moved to: nodename nor servname provided, or not known
# /Users/viktor/oh-my-zsh-fork/plugins/copyshell/copyshell.plugin.zsh:22: parse error near `}'

#no gitconfig