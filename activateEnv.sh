#----------------------------------------------------------------------
# Robin's Python Wrangler
# 
# This script can be used to easily switch the active Python (that
# found first on the PATH) to any one of a set of Python environments
# configured in ~/.myPyEnv and to keep track of which is active.  Both
# full Python install trees and virtual environments can be managed in
# this way.
#
# If you use cygwin bash on Windows with native Windows Pythons then
# this script will also work for you there.  You just need to
# configure your environments in ~/.myPyEnv with the cygwin paths,
# not the Windows paths.  I expect that this script will also work with
# cygwin Pythons too, but I don't use that myself so it hasn't been
# tested.
#
# Once a Python has been activated then there will be some additional
# command-line commands available to you:
#
#     deactivate:     Just like virtualenv this will reset your command-
#                     line environment to what it was before the
#                     activation.  The environments don't stack up, if
#                     one is already active then it is deactivated
#                     before activating the next one.
#
#     cdenv:          chdir to the root of the environment
#
#     cdsitepackages: chdir to the environment's site-packages folder.

# NOTE: "source" this script in bash, running normally in a subshell
#       will not have the desired effect.  An easy way to not have to
#       remember this is to make a bash alias, such as:
#
#           alias activateEnv="source ~/bin/activateEnv.sh"
#       or:
#           alias workon="source ~/bin/activateEnv.sh"
#
#       if you have virtualenvwrapper muscle-memory
#
# NOTE2: This script assumes that there is already some python available 
#        on the PATH that can be used to look up the environment paths
#        that can be switched to.
#
#----------------------------------------------------------------------

#set -o xtrace

EnvMapper=~/.myPyEnv
_ActivateScript=

#----------------------------------------------------------------------

usage () {
    echo "Usage: "
    echo "       source activateEnv.sh [--reset] env-name"
    echo "       activateEnv.sh --list"
    echo "       activateEnv.sh --help"
    echo ""

    echo "Activates a named Python virtual env, setting it up first if"
    echo "neccessary.  The available environments are defined by a python"
    echo "script in $EnvMapper, which should take an env name"
    echo "on the command line and output the path where that env is located."

}



main () {
    local BASEDIR
    local BIN=bin
    local EXT=
    local RESET=no

    if [ "$OSTYPE" == "cygwin" ]; then 
	EnvMapper=`cygpath -m $EnvMapper`
	BIN=Scripts
	EXT=.exe
    fi

    if [ $# -lt 1 -o "$1" == "--help" ]; then
	usage
	return 1
    fi

    if [ "$1" == "--list" ]; then
	python $EnvMapper --list
	return 1
    fi
    
    if [ "$1" == "--reset" ]; then 
	RESET=yes
	shift
    fi

    BASEDIR=`python $EnvMapper $1`
    if [ "$?" != "0" ]; then 
	echo "Unable to select ENV $1"
	return 1
    fi

    # Setup the Scripts dir on Windows.  It may not exist yet if
    # nothing has been installed, and we'll also add some aliases as
    # symlinks so cygwin can find python.exe, etc.
    if [ "$OSTYPE" == "cygwin" ]; then
	if [ ! -e $BASEDIR/Scripts ]; then
	    mkdir $BASEDIR/Scripts
	fi
	if [ ! -e $BASEDIR/Scripts/python.exe ]; then
	    cd $BASEDIR/Scripts
	    ln -s ../python*.exe .
	    cd -
	fi
	# Add a bin link too??  I like it, but others may not.
	#if [ ! -e $BASEDIR/bin ]; then
        #    ln -s Scripts $BASEDIR/bin
	#fi
    fi

    _ActivateScript=$BASEDIR/$BIN/activate

    # Write the activation sctipt into the env if it 
    # doesn't already have one
    if [ ! -e $_ActivateScript -o "$RESET" == "yes" ]; then
        writeActivateScript $BASEDIR $1 $_ActivateScript $BIN
    fi

    if [ ! -e $BASEDIR/$BIN/python$EXT ]; then
	echo "WARNING: No $BIN/python$EXE found in environment"
	if [ -e $BASEDIR/$BIN/python3$EXT ]; then
	    echo -e "\tbut $BIN/python3$EXT does exist, be sure to use it instead."
	fi
    fi

    return 0
}




writeActivateScript () {
    local BASEDIR=$1
    local PROMPT=$2
    local SCRIPT=$3
    local BIN=$4

    if [ -e $SCRIPT ]; then
	mv $SCRIPT $SCRIPT.save
    fi

    echo "Writing new activate script."
    cat <<-"EOF" | sed s!@BASEDIR@!$BASEDIR! | sed s!@PROMPT@!$PROMPT! | sed s!@BIN@!$BIN!  > $SCRIPT
	# This file must be used with "source bin/activate" *from bash*
	# you cannot run it directly
	
	deactivate () {
	    # reset old environment variables
	    if [ -n "$_OLD_VIRTUAL_PATH" ] ; then
	        PATH="$_OLD_VIRTUAL_PATH"
	        export PATH
	        unset _OLD_VIRTUAL_PATH
	    fi
	    if [ -n "$_OLD_VIRTUAL_PYTHONHOME" ] ; then
	        PYTHONHOME="$_OLD_VIRTUAL_PYTHONHOME"
	        export PYTHONHOME
	        unset _OLD_VIRTUAL_PYTHONHOME
	    fi

	    # This should detect bash and zsh, which have a hash command that must
	    # be called to get it to forget past commands.  Without forgetting
	    # past commands the $PATH changes we made may not be respected
	    if [ -n "$BASH" -o -n "$ZSH_VERSION" ] ; then
	        hash -r
	    fi
	
	    if [ -n "$_OLD_VIRTUAL_PS1" ] ; then
	        PS1="$_OLD_VIRTUAL_PS1"
	        export PS1
	        unset _OLD_VIRTUAL_PS1
	    fi

	    unset VIRTUAL_ENV
	    if [ ! "$1" = "nondestructive" ] ; then
	        # Self destruct!
	        unset -f deactivate
	        unset -f cdenv
	        unset -f cdsitepackages
	    fi
	}

	cdenv () {
	    if [ -d "$VIRTUAL_ENV" ]; then
	        cd "$VIRTUAL_ENV"
	    else
	        echo "\"$VIRTUAL_ENV\" does not exist!"
	        return 1
	    fi
	}

	cdsitepackages () {
	    if [ -d "$VIRTUAL_ENV"/Lib/site-packages ]; then 
	        cd "$VIRTUAL_ENV"/Lib/site-packages
	    elif [ -d "$VIRTUAL_ENV"/lib/python?.?/site-packages ]; then
	        cd  "$VIRTUAL_ENV"/lib/python?.?/site-packages
	    else	
	        echo "site-packages not found in \"$VIRTUAL_ENV\""
	        return 1
	    fi
	}


	# unset irrelavent variables
	deactivate nondestructive

	VIRTUAL_ENV="@BASEDIR@"
	export VIRTUAL_ENV

	_OLD_VIRTUAL_PATH="$PATH"
	PATH="$VIRTUAL_ENV/@BIN@:$PATH"
	export PATH

	# unset PYTHONHOME if set
	# this will fail if PYTHONHOME is set to the empty string (which is bad anyway)
	# could use `if (set -u; : $PYTHONHOME) ;` in bash
	if [ -n "$PYTHONHOME" ] ; then
	    _OLD_VIRTUAL_PYTHONHOME="$PYTHONHOME"
	    unset PYTHONHOME
	fi

	if [ -z "$VIRTUAL_ENV_DISABLE_PROMPT" ] ; then
	    _OLD_VIRTUAL_PS1="$PS1"
	    PS1="(@PROMPT@)$PS1"
	    export PS1
	fi

	# This should detect bash and zsh, which have a hash command that must
	# be called to get it to forget past commands.  Without forgetting
	# past commands the $PATH changes we made may not be respected
	if [ -n "$BASH" -o -n "$ZSH_VERSION" ] ; then
	    hash -r
	fi
	EOF
}


cleanup () {
    unset -f main
    unset -f usage
    unset -f writeActivateScript
    unset -f cleanup
    unset EnvMapper
}

#----------------------------------------------------------------------
# Get the show on the road...

main "$@"
if [ ! $? ]; then 
    cleanup
    return 1
fi

cleanup

if [ -z $_ActivateScript ]; then
    return
fi

echo -e "Activating environment with:\n\t $_ActivateScript"
source $_ActivateScript
unset _ActivateScript

#set +o xtrace
