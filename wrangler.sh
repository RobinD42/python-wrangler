#
#
# NOTE: "source" this in bash, running normally in a subshell 
#       will not have the desired effect.
#
#

#set -o xtrace

EnvMapper_txt="~/.myPyEnv"
EnvMapper=~/.myPyEnv
_ActivateScript=

VERSION=2.1

#----------------------------------------------------------------------

usage () {
    echo "Usage: "
    echo "       source wrangler.sh [--reset] env-name"
    echo "       wrangler.sh --list"
    echo "       wrangler.sh --help"
    echo ""

    echo "Activates a named Python [virtual] env, setting it up first if"
    echo "neccessary.  The available environments are defined by files,"
    echo "links or folders located in in $EnvMapper_txt. Items there provide"
    echo "a map from a simple name (the item in $EnvMapper_txt) to the base"
    echo "dir of a Python installation or virtual environment. It should"
    echo "be either a symlink to the Python environment, a file that"
    echo "contains the path to the Python environment, or the Python"
    echo "environment itself.  Finally, wrangler can also be used without"
    echo "an item in the $EnvMapper_txt folder, just give a full or relative"
    echo "path to the environment you want to switch to."
}


get_basedir () {
    # Given a path (should be an item in $EnvMapper) determine where
    # the target Python environment is located and echo that value.
    local ITEM=$1
    local DIR
    
    if [ -L $ITEM ]; then
	# if it is a symlink
	DIR=$(readlink -f $ITEM)
	
    elif [ -d $ITEM ]; then
	# if it is a dir, canonicalize it
	DIR=$(readlink -f $ITEM)

    elif [ -f $ITEM ]; then
	# if it's a regular file then use the contents as-is
	DIR=$(cat $ITEM)
    else
	>&2 echo "ERROR: I don't know what to do with $ITEM"
	return 1
    fi

    echo $DIR
}


main () {
    local BASEDIR
    local BIN=bin
    local EXT=
    local RESET=no

    echo "Python Wrangler:" $VERSION

    if [ "$OSTYPE" == "cygwin" ]; then 
	BIN=Scripts
	EXT=.exe
    fi

    if [ $# -lt 1 -o "$1" == "--help" ]; then
	usage
	return 0
    fi

    if [ "$1" == "--list" ]; then
	for f in $EnvMapper/*; do
	    printf "%10s: %s\n" "$(basename $f)"  "$(get_basedir $f)"
	done
	return 0
    fi
    
    if [ "$1" == "--reset" ]; then 
	RESET=yes
	shift
    fi

    if [ -d $1 ]; then
        BASEDIR=$(readlink -f $1)
    elif [ -e $EnvMapper/$1 ]; then
	BASEDIR=$(get_basedir $EnvMapper/$1)
    else
     	echo "Unable to select ENV $1"
	return 1
    fi

    # Setup the Scripts dir on Windows.  It may not exist yet if
    # nothing has been installed, and we'll also add some aliases
    if [ "$OSTYPE" == "cygwin" ]; then
	if [ ! -e "$BASEDIR/Scripts" ]; then
	    mkdir "$BASEDIR/Scripts"
	fi
	# add a bin link too
	if [ ! -e "$BASEDIR/bin" ]; then
            ln -s Scripts "$BASEDIR/bin"
	fi
    fi

    _ActivateScript="$BASEDIR/$BIN/activate"

    # Write the activation sctipt into the env if it 
    # doesn't already have one
    if [ ! -e "$_ActivateScript" -o "$RESET" == "yes" ]; then
        writeActivateScript "$BASEDIR" $(basename $1) "$_ActivateScript" $BIN
    fi

    if [ ! -e "$BASEDIR/$BIN/python$EXT" ]; then
	echo "WARNING: No $BIN/python$EXE found in environment"
	if [ -e "$BASEDIR/$BIN/python3$EXT" ]; then
	    echo -e "\tbut $BIN/python3$EXT does exist, be sure to use it instead."
	    echo -e "\tOr you can do: cp $BIN/python3$EXT $BIN/python$EXT"
	fi
    fi

    # add my favorite alias
    if [ ! -e "$BASEDIR/$BIN/py" -o "$RESET" == "yes" ]; then
	rm -f $BASEDIR/$BIN/py
	echo "Adding alias $BASEDIR/$BIN/py"
	if [ -e "$BASEDIR/$BIN/python3$EXT" ]; then
	    ln -s python3$EXT $BASEDIR/$BIN/py
	else
	    ln -s python$EXT $BASEDIR/$BIN/py
	fi
    fi

    return 0
}




writeActivateScript () {
    local BASEDIR=$1
    local PROMPT=$2
    local SCRIPT=$3
    local BIN=$4

    if [ -e "$SCRIPT" ]; then
	mv "$SCRIPT" "$SCRIPT.save"
    fi

    echo "Writing new activate script."
    cat <<-"EOF" | sed "s!@BASEDIR@!$BASEDIR!" | sed s!@PROMPT@!$PROMPT! | sed s!@BIN@!$BIN!  > "$SCRIPT"
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

	VIRTUAL_ENV=$(cd "@BASEDIR@" && pwd)
	export VIRTUAL_ENV

	_OLD_VIRTUAL_PATH="$PATH"
	PATH="$VIRTUAL_ENV/@BIN@:$PATH"
	if [ "$OSTYPE" == "cygwin" ]; then 
            PATH="$VIRTUAL_ENV:$PATH"
	fi
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

if [ -z "$_ActivateScript" ]; then
    return
fi

echo -e "Activating environment with:\n\t $_ActivateScript"
source "$_ActivateScript"
unset _ActivateScript

#set +o xtrace
