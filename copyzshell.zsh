#!/bin/zsh
if [[ ! ARGC -eq 1 ]] then
	echo "1 argument required, $# provided"
	exit 1
elif [[ $1 = '-h' || $1 = '--help' ]] then
	echo "HELP MSG"
	exit 0 
else
	# exit on failure!
	set -e
	zmodload zsh/regex
	#check that the ZSH path is not wierd
	if [[ ! $ZSH -regex-match ^$HOME/(.+) ]] then
		echo "Your ZSH folder "$ZSH" doesn't seem to be in your home folder. Quitting"
		exit 1
	fi
	
	DATESTR=$(date "+%Y-%m-%d-%H:%M:%S")
	ZSH_FOLDER=${ZSH#$HOME/} # could be in multiple subfolders relative to $HOME TODO TEST!
	ZSH_BASE=${ZSH##*/}
	ZSH_FOLDER_WITHOUT_BASE=./${ZSH_FOLDER%$ZSH_BASE}
	echo $ZSH_FOLDER
	echo $ZSH_FOLDER_WITHOUT_BASE
	#mkdir -p

	cd ~
	
	# We want to move all files in a batch so we don't have to ask for passwords so much.

	# move our files into a subdirectory of tmp so that we don't have to worry about 
	# permissions when overwriting old files on the remote machine.
	# Otherwise, this can happen with .git objects when a previous run of this script
	# failed for some reason.
	echo Transfering $ZSH, .zshrc and .gitconfig.
	TMP_DIR=/tmp/copyshell_$DATESTR
	mkdir $TMP_DIR
	cp -r $ZSH $TMP_DIR/oh-my-zsh
	echo cp -r $ZSH $TMP_DIR/oh-my-zsh
	cp .zshrc $TMP_DIR
	cp .gitconfig $TMP_DIR
	echo 	scp -r $TMP_DIR $1":"$TMP_DIR
	scp -r $TMP_DIR $1":"$TMP_DIR
	echo "files should now be in "$TMP_DIR

	# rc=$?
	#DO NOT TRANSFER WIERD GIT FILES!
	# if [[ ! $rc = 1 && ! $rc = 0 ]] ; then
	# 	echo "failing because error " $rc
	# 	exit $rc
	# fi

	echo 'File transfer complete. We will now setup the shell via ssh.'

	remote_commands="
	set -e
	cd ~
	
	# check for pre-existing zsh folder!
	if [[ -d $ZSH_FOLDER ]]; then
		echo $ZSH_FOLDER folder aldready exists, copying it to ${ZSH_FOLDER}_${DATESTR};
		mv $ZSH_FOLDER ${ZSH_FOLDER}_${DATESTR}; 
	fi

	#move the new zsh folder into position
	mkdir -p $ZSH_FOLDER_WITHOUT_BASE
	mv ${TMP_DIR}/oh-my-zsh $ZSH_FOLDER

	# check for pre-existing files
	if [ -f .zshrc ]; then 
		mv .zshrc .zshrc_$DATESTR 
		echo 'An existing .zshrc was found. It was moved to .zshrc_$DATESTR'
	fi
	if [ -f .gitconfig ]; then 
		mv .gitconfig .gitconfig_$DATESTR
		echo 'An existing .gitconfig was found. It was moved to .gitconfig_$DATESTR'
	fi

	# move the new files into position
	mv ${TMP_DIR}/.zshrc .zshrc
	mv ${TMP_DIR}/.gitconfig .gitconfig

	#check that zsh is installed
	command -v zsh1 >/dev/null 2>&1
	if [[ \$? -eq 1 ]]; then
    	echo 'zsh does not appear to be installed. Your configuration is prepared, so install zsh and then change your shell using 'chsh -s /bin/zsh', and your configuration should become active.'
	else
		chsh -s /bin/zsh
	fi"
	echo "$remote_commands"
	echo "Starting remote session:"
	ssh -t $1 "echo '$remote_commands' | sh"
fi