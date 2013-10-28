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
	
	zsh_folder=${ZSH#$HOME/} # could be in multiple subfolders relative to $HOME TODO TEST!
	zsh_base=${ZSH##*/}
	zsh_folder_without_base=./${ZSH_folder%$zsh_base}
	echo $zsh_folder
	echo $zsh_folder_without_base
	echo "2"
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
	#TODO: better error msg in case of transfer failure (esp. permissions)
	echo File transfer complete. We will now setup the shell via ssh.

	#todo: take into account usernames!!
	ssh -t $1 '

	# this will be run in *gulp* bash ?
	cd ~
	#exit on failure!
	
	#check for pre-existing zsh folder!
	if [[ -d '$zsh_folder' ]]; then
		echo 1
		echo Folder aldready exists!;
		echo mv '$zsh_folder' '$zsh_folder'_'$datestr';
		mv '$zsh_folder' '$zsh_folder_$datestr'; 
	fi
	mkdir -p '$zsh_folder_without_base'
	echo mv /tmp/'$zsh_base' '$zsh_folder'
	mv /tmp/'$zsh_base' '$zsh_folder'


	if [ -f .zshrc ]; then 
		mv .zshrc .zshrc_'$datestr' 
		echo "An existing .zshrc was found. It was moved to .zshrc_'$datestr'"
	fi

	if [ -f .gitconfig ]; then 
		mv .gitconfig .gitconfig_'$datestr'
		echo "An existing .gitconfig was found. It was moved to .gitconfig_'$datestr'"
	fi

	mv /tmp/.zshrc .zshrc
	mv /tmp/.gitconfig .gitconfig


	chsh -s /bin/zsh'
fi

# Transfering .oh-my-zsh, .zshrc, .gitconfig and this script:
# :~/: No such file or directory
# We will now setup the shell via ssh.
# ssh: Could not resolve hostname if [ -f .zshrc ]; then
# 	mv .zshrc .zshrc_old;
# 	echo "An existing .zshrc was found. It was moved to: nodename nor servname provided, or not known
# /Users/viktor/oh-my-zsh-fork/plugins/copyshell/copyshell.plugin.zsh:22: parse error near `}'

#no gitconfig