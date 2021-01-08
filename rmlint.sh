#!/bin/sh

PROGRESS_CURR=0
PROGRESS_TOTAL=190                         

# This file was autowritten by rmlint
# rmlint was executed from: /home/borto/Github/Compiti-scolastici/
# Your command line was: rmlint -g

RMLINT_BINARY="/usr/bin/rmlint"

# Only use sudo if we're not root yet:
# (See: https://github.com/sahib/rmlint/issues/27://github.com/sahib/rmlint/issues/271)
SUDO_COMMAND="sudo"
if [ "$(id -u)" -eq "0" ]
then
  SUDO_COMMAND=""
fi

USER='borto'
GROUP='borto'

# Set to true on -n
DO_DRY_RUN=

# Set to true on -p
DO_PARANOID_CHECK=

# Set to true on -r
DO_CLONE_READONLY=

# Set to true on -q
DO_SHOW_PROGRESS=true

# Set to true on -c
DO_DELETE_EMPTY_DIRS=

# Set to true on -k
DO_KEEP_DIR_TIMESTAMPS=

# Set to true on -i
DO_ASK_BEFORE_DELETE=

##################################
# GENERAL LINT HANDLER FUNCTIONS #
##################################

COL_RED='[0;31m'
COL_BLUE='[1;34m'
COL_GREEN='[0;32m'
COL_YELLOW='[0;33m'
COL_RESET='[0m'

print_progress_prefix() {
    if [ -n "$DO_SHOW_PROGRESS" ]; then
        PROGRESS_PERC=0
        if [ $((PROGRESS_TOTAL)) -gt 0 ]; then
            PROGRESS_PERC=$((PROGRESS_CURR * 100 / PROGRESS_TOTAL))
        fi
        printf '%s[%3d%%]%s ' "${COL_BLUE}" "$PROGRESS_PERC" "${COL_RESET}"
        if [ $# -eq "1" ]; then
            PROGRESS_CURR=$((PROGRESS_CURR+$1))
        else
            PROGRESS_CURR=$((PROGRESS_CURR+1))
        fi
    fi
}

handle_emptyfile() {
    print_progress_prefix
    echo "${COL_GREEN}Deleting empty file:${COL_RESET} $1"
    if [ -z "$DO_DRY_RUN" ]; then
        rm -f "$1"
    fi
}

handle_emptydir() {
    print_progress_prefix
    echo "${COL_GREEN}Deleting empty directory: ${COL_RESET}$1"
    if [ -z "$DO_DRY_RUN" ]; then
        rmdir "$1"
    fi
}

handle_bad_symlink() {
    print_progress_prefix
    echo "${COL_GREEN} Deleting symlink pointing nowhere: ${COL_RESET}$1"
    if [ -z "$DO_DRY_RUN" ]; then
        rm -f "$1"
    fi
}

handle_unstripped_binary() {
    print_progress_prefix
    echo "${COL_GREEN} Stripping debug symbols of: ${COL_RESET}$1"
    if [ -z "$DO_DRY_RUN" ]; then
        strip -s "$1"
    fi
}

handle_bad_user_id() {
    print_progress_prefix
    echo "${COL_GREEN}chown ${USER}${COL_RESET} $1"
    if [ -z "$DO_DRY_RUN" ]; then
        chown "$USER" "$1"
    fi
}

handle_bad_group_id() {
    print_progress_prefix
    echo "${COL_GREEN}chgrp ${GROUP}${COL_RESET} $1"
    if [ -z "$DO_DRY_RUN" ]; then
        chgrp "$GROUP" "$1"
    fi
}

handle_bad_user_and_group_id() {
    print_progress_prefix
    echo "${COL_GREEN}chown ${USER}:${GROUP}${COL_RESET} $1"
    if [ -z "$DO_DRY_RUN" ]; then
        chown "$USER:$GROUP" "$1"
    fi
}

###############################
# DUPLICATE HANDLER FUNCTIONS #
###############################

check_for_equality() {
    if [ -f "$1" ]; then
        # Use the more lightweight builtin `cmp` for regular files:
        cmp -s "$1" "$2"
        echo $?
    else
        # Fallback to `rmlint --equal` for directories:
        "$RMLINT_BINARY" -p --equal  "$1" "$2"
        echo $?
    fi
}

original_check() {
    if [ ! -e "$2" ]; then
        echo "${COL_RED}^^^^^^ Error: original has disappeared - cancelling.....${COL_RESET}"
        return 1
    fi

    if [ ! -e "$1" ]; then
        echo "${COL_RED}^^^^^^ Error: duplicate has disappeared - cancelling.....${COL_RESET}"
        return 1
    fi

    # Check they are not the exact same file (hardlinks allowed):
    if [ "$1" = "$2" ]; then
        echo "${COL_RED}^^^^^^ Error: original and duplicate point to the *same* path - cancelling.....${COL_RESET}"
        return 1
    fi

    # Do double-check if requested:
    if [ -z "$DO_PARANOID_CHECK" ]; then
        return 0
    else
        if [ "$(check_for_equality "$1" "$2")" -ne "0" ]; then
            echo "${COL_RED}^^^^^^ Error: files no longer identical - cancelling.....${COL_RESET}"
            return 1
        fi
    fi
}

cp_symlink() {
    print_progress_prefix
    echo "${COL_YELLOW}Symlinking to original: ${COL_RESET}$1"
    if original_check "$1" "$2"; then
        if [ -z "$DO_DRY_RUN" ]; then
            # replace duplicate with symlink
            rm -rf "$1"
            ln -s "$2" "$1"
            # make the symlink's mtime the same as the original
            touch -mr "$2" -h "$1"
        fi
    fi
}

cp_hardlink() {
    if [ -d "$1" ]; then
        # for duplicate dir's, can't hardlink so use symlink
        cp_symlink "$@"
        return $?
    fi
    print_progress_prefix
    echo "${COL_YELLOW}Hardlinking to original: ${COL_RESET}$1"
    if original_check "$1" "$2"; then
        if [ -z "$DO_DRY_RUN" ]; then
            # replace duplicate with hardlink
            rm -rf "$1"
            ln "$2" "$1"
        fi
    fi
}

cp_reflink() {
    if [ -d "$1" ]; then
        # for duplicate dir's, can't clone so use symlink
        cp_symlink "$@"
        return $?
    fi
    print_progress_prefix
    # reflink $1 to $2's data, preserving $1's  mtime
    echo "${COL_YELLOW}Reflinking to original: ${COL_RESET}$1"
    if original_check "$1" "$2"; then
        if [ -z "$DO_DRY_RUN" ]; then
            touch -mr "$1" "$0"
            if [ -d "$1" ]; then
                rm -rf "$1"
            fi
            cp --archive --reflink=always "$2" "$1"
            touch -mr "$0" "$1"
        fi
    fi
}

clone() {
    print_progress_prefix
    # clone $1 from $2's data
    # note: no original_check() call because rmlint --dedupe takes care of this
    echo "${COL_YELLOW}Cloning to: ${COL_RESET}$1"
    if [ -z "$DO_DRY_RUN" ]; then
        if [ -n "$DO_CLONE_READONLY" ]; then
            $SUDO_COMMAND $RMLINT_BINARY --dedupe  --dedupe-readonly "$2" "$1"
        else
            $RMLINT_BINARY --dedupe  "$2" "$1"
        fi
    fi
}

skip_hardlink() {
    print_progress_prefix
    echo "${COL_BLUE}Leaving as-is (already hardlinked to original): ${COL_RESET}$1"
}

skip_reflink() {
    print_progress_prefix
    echo "${COL_BLUE}Leaving as-is (already reflinked to original): ${COL_RESET}$1"
}

user_command() {
    print_progress_prefix

    echo "${COL_YELLOW}Executing user command: ${COL_RESET}$1"
    if [ -z "$DO_DRY_RUN" ]; then
        # You can define this function to do what you want:
        echo 'no user command defined.'
    fi
}

remove_cmd() {
    print_progress_prefix
    echo "${COL_YELLOW}Deleting: ${COL_RESET}$1"
    if original_check "$1" "$2"; then
        if [ -z "$DO_DRY_RUN" ]; then
            if [ -n "$DO_KEEP_DIR_TIMESTAMPS" ]; then
                touch -r "$(dirname "$1")" "$STAMPFILE"
            fi
            if [ -n "$DO_ASK_BEFORE_DELETE" ]; then
              rm -ri "$1"
            else
              rm -rf "$1"
            fi
            if [ -n "$DO_KEEP_DIR_TIMESTAMPS" ]; then
                # Swap back old directory timestamp:
                touch -r "$STAMPFILE" "$(dirname "$1")"
                rm "$STAMPFILE"
            fi

            if [ -n "$DO_DELETE_EMPTY_DIRS" ]; then
                DIR=$(dirname "$1")
                while [ ! "$(ls -A "$DIR")" ]; do
                    print_progress_prefix 0
                    echo "${COL_GREEN}Deleting resulting empty dir: ${COL_RESET}$DIR"
                    rmdir "$DIR"
                    DIR=$(dirname "$DIR")
                done
            fi
        fi
    fi
}

original_cmd() {
    print_progress_prefix
    echo "${COL_GREEN}Keeping:  ${COL_RESET}$1"
}

##################
# OPTION PARSING #
##################

ask() {
    cat << EOF

This script will delete certain files rmlint found.
It is highly advisable to view the script first!

Rmlint was executed in the following way:

   $ rmlint -g

Execute this script with -d to disable this informational message.
Type any string to continue; CTRL-C, Enter or CTRL-D to abort immediately
EOF
    read -r eof_check
    if [ -z "$eof_check" ]
    then
        # Count Ctrl-D and Enter as aborted too.
        echo "${COL_RED}Aborted on behalf of the user.${COL_RESET}"
        exit 1;
    fi
}

usage() {
    cat << EOF
usage: $0 OPTIONS

OPTIONS:

  -h   Show this message.
  -d   Do not ask before running.
  -x   Keep rmlint.sh; do not autodelete it.
  -p   Recheck that files are still identical before removing duplicates.
  -r   Allow deduplication of files on read-only btrfs snapshots. (requires sudo)
  -n   Do not perform any modifications, just print what would be done. (implies -d and -x)
  -c   Clean up empty directories while deleting duplicates.
  -q   Do not show progress.
  -k   Keep the timestamp of directories when removing duplicates.
  -i   Ask before deleting each file
EOF
}

DO_REMOVE=
DO_ASK=

while getopts "dhxnrpqcki" OPTION
do
  case $OPTION in
     h)
       usage
       exit 0
       ;;
     d)
       DO_ASK=false
       ;;
     x)
       DO_REMOVE=false
       ;;
     n)
       DO_DRY_RUN=true
       DO_REMOVE=false
       DO_ASK=false
       DO_ASK_BEFORE_DELETE=false
       ;;
     r)
       DO_CLONE_READONLY=true
       ;;
     p)
       DO_PARANOID_CHECK=true
       ;;
     c)
       DO_DELETE_EMPTY_DIRS=true
       ;;
     q)
       DO_SHOW_PROGRESS=
       ;;
     k)
       DO_KEEP_DIR_TIMESTAMPS=true
       STAMPFILE=$(mktemp 'rmlint.XXXXXXXX.stamp')
       ;;
     i)
       DO_ASK_BEFORE_DELETE=true
       ;;
     *)
       usage
       exit 1
  esac
done

if [ -z $DO_REMOVE ]
then
    echo "#${COL_YELLOW} ///${COL_RESET}This script will be deleted after it runs${COL_YELLOW}///${COL_RESET}"
fi

if [ -z $DO_ASK ]
then
  usage
  ask
fi

if [ -n "$DO_DRY_RUN" ]
then
    echo "#${COL_YELLOW} ////////////////////////////////////////////////////////////${COL_RESET}"
    echo "#${COL_YELLOW} /// ${COL_RESET} This is only a dry run; nothing will be modified! ${COL_YELLOW}///${COL_RESET}"
    echo "#${COL_YELLOW} ////////////////////////////////////////////////////////////${COL_RESET}"
fi

######### START OF AUTOGENERATED OUTPUT #########


original_cmd  '/home/borto/Github/Compiti-scolastici/_site/robots.txt' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/robots.txt' '/home/borto/Github/Compiti-scolastici/_site/robots.txt' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/drawio/32-pagina-258' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/drawio/32-pagina-258' '/home/borto/Github/Compiti-scolastici/_site/data/drawio/32-pagina-258' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/drawio/44-pagina-285' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/drawio/44-pagina-285' '/home/borto/Github/Compiti-scolastici/_site/data/drawio/44-pagina-285' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/drawio/33-pagina-259' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/drawio/33-pagina-259' '/home/borto/Github/Compiti-scolastici/_site/data/drawio/33-pagina-259' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/drawio/Untitled Diagram' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/drawio/Untitled Diagram' '/home/borto/Github/Compiti-scolastici/_site/data/drawio/Untitled Diagram' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/drawio/Prometheus Iapeti Filius' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/drawio/Prometheus Iapeti Filius' '/home/borto/Github/Compiti-scolastici/_site/data/drawio/Prometheus Iapeti Filius' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/favicon/android-icon-36x36.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/android-icon-36x36.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/android-icon-36x36.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/favicon/android-icon-48x48.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/android-icon-48x48.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/android-icon-48x48.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/favicon/apple-icon-114x114.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/apple-icon-114x114.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/apple-icon-114x114.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/favicon/apple-icon-57x57.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/apple-icon-57x57.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/apple-icon-57x57.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/favicon/apple-icon-120x120.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/apple-icon-120x120.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/apple-icon-120x120.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/favicon/apple-icon-60x60.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/apple-icon-60x60.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/apple-icon-60x60.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/favicon/browserconfig.xml' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/browserconfig.xml' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/browserconfig.xml' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/favicon/favicon-16x16.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/favicon-16x16.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/favicon-16x16.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/favicon/favicon-32x32.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/favicon-32x32.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/favicon-32x32.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/favicon/favicon.ico' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/favicon.ico' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/favicon.ico' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/favicon/android-icon-72x72.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/_site/data/favicon/apple-icon-72x72.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/android-icon-72x72.png' # duplicate
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/android-icon-72x72.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/android-icon-72x72.png' # duplicate
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/apple-icon-72x72.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/android-icon-72x72.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/favicon/html.txt' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/html.txt' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/html.txt' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/favicon/manifest.json' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/manifest.json' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/manifest.json' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/favicon/apple-icon-76x76.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/apple-icon-76x76.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/apple-icon-76x76.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/favicon/android-icon-96x96.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/_site/data/favicon/favicon-96x96.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/android-icon-96x96.png' # duplicate
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/android-icon-96x96.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/android-icon-96x96.png' # duplicate
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/favicon-96x96.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/android-icon-96x96.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/favicon/apple-icon-152x152.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/apple-icon-152x152.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/apple-icon-152x152.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/favicon/apple-icon-180x180.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/apple-icon-180x180.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/apple-icon-180x180.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/favicon/ms-icon-70x70.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/ms-icon-70x70.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/ms-icon-70x70.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/favicon/ms-icon-150x150.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/ms-icon-150x150.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/ms-icon-150x150.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/favicon/android-icon-144x144.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/_site/data/favicon/apple-icon-144x144.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/android-icon-144x144.png' # duplicate
remove_cmd    '/home/borto/Github/Compiti-scolastici/_site/data/favicon/ms-icon-144x144.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/android-icon-144x144.png' # duplicate
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/android-icon-144x144.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/android-icon-144x144.png' # duplicate
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/apple-icon-144x144.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/android-icon-144x144.png' # duplicate
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/ms-icon-144x144.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/android-icon-144x144.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/printer.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/printer.png' '/home/borto/Github/Compiti-scolastici/_site/data/img/printer.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data.csv' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/fisica/lss/moto/codiciverynoobs/data.csv' '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data.csv' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data0.csv' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/fisica/lss/moto/codiciverynoobs/data0.csv' '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data0.csv' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data0_long.csv' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/fisica/lss/moto/codiciverynoobs/data0_long.csv' '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data0_long.csv' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data2.csv' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/fisica/lss/moto/codiciverynoobs/data2.csv' '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data2.csv' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data2_long.csv' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/fisica/lss/moto/codiciverynoobs/data2_long.csv' '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data2_long.csv' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data3.csv' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/fisica/lss/moto/codiciverynoobs/data3.csv' '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data3.csv' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data3_long.csv' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/fisica/lss/moto/codiciverynoobs/data3_long.csv' '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data3_long.csv' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data4.csv' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/fisica/lss/moto/codiciverynoobs/data4.csv' '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data4.csv' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data4_long.csv' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/fisica/lss/moto/codiciverynoobs/data4_long.csv' '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data4_long.csv' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data1_long.csv' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/fisica/lss/moto/codiciverynoobs/data1_long.csv' '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data1_long.csv' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data5.csv' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/fisica/lss/moto/codiciverynoobs/data5.csv' '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data5.csv' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data1.csv' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/fisica/lss/moto/codiciverynoobs/data1.csv' '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data1.csv' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data5_long.csv' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/fisica/lss/moto/codiciverynoobs/data5_long.csv' '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data5_long.csv' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data6_long.csv' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/fisica/lss/moto/codiciverynoobs/data6_long.csv' '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data6_long.csv' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data6.csv' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/fisica/lss/moto/codiciverynoobs/data6.csv' '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/data6.csv' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/fisicastats.py' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/fisica/lss/moto/codiciverynoobs/fisicastats.py' '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/fisicastats.py' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/fisicastatsbackup.py' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/fisica/lss/moto/codiciverynoobs/fisicastatsbackup.py' '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/fisicastatsbackup.py' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/fisicastatsbackup2.py' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/fisica/lss/moto/codiciverynoobs/fisicastatsbackup2.py' '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/codiciverynoobs/fisicastatsbackup2.py' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/appunti/fluidi/torchio_idraulico.svg' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/fisica/appunti/fluidi/torchio_idraulico.svg' '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/appunti/fluidi/torchio_idraulico.svg' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/loghi/aereo.svg' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/loghi/aereo.svg' '/home/borto/Github/Compiti-scolastici/_site/data/img/loghi/aereo.svg' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/loghi/instagram.svg' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/loghi/instagram.svg' '/home/borto/Github/Compiti-scolastici/_site/data/img/loghi/instagram.svg' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/text/chimica/lss/acidi-e-basi/WordCloudBase.txt' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/text/chimica/lss/acidi-e-basi/WordCloudBase.txt' '/home/borto/Github/Compiti-scolastici/_site/data/text/chimica/lss/acidi-e-basi/WordCloudBase.txt' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/js/prof-view.js' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/js/prof-view.js' '/home/borto/Github/Compiti-scolastici/_site/js/prof-view.js' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/loghi/dado.svg' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/loghi/dado.svg' '/home/borto/Github/Compiti-scolastici/_site/data/img/loghi/dado.svg' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/js/simple-jekyll-search.min.js' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/js/simple-jekyll-search.min.js' '/home/borto/Github/Compiti-scolastici/_site/js/simple-jekyll-search.min.js' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/js/simple-jekyll-search.js' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/js/simple-jekyll-search.js' '/home/borto/Github/Compiti-scolastici/_site/js/simple-jekyll-search.js' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/js/fisica/moti-irregolari-plotly.js' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/js/fisica/moti-irregolari-plotly.js' '/home/borto/Github/Compiti-scolastici/_site/js/fisica/moti-irregolari-plotly.js' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/loghi/github.svg' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/loghi/github.svg' '/home/borto/Github/Compiti-scolastici/_site/data/img/loghi/github.svg' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/favicon/android-icon-192x192.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/_site/data/favicon/apple-icon-precomposed.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/android-icon-192x192.png' # duplicate
remove_cmd    '/home/borto/Github/Compiti-scolastici/_site/data/favicon/apple-icon.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/android-icon-192x192.png' # duplicate
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/android-icon-192x192.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/android-icon-192x192.png' # duplicate
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/apple-icon-precomposed.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/android-icon-192x192.png' # duplicate
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/apple-icon.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/android-icon-192x192.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/fonts/Abel.ttf' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/fonts/Abel.ttf' '/home/borto/Github/Compiti-scolastici/_site/data/fonts/Abel.ttf' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/favicon/ms-icon-310x310.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/favicon/ms-icon-310x310.png' '/home/borto/Github/Compiti-scolastici/_site/data/favicon/ms-icon-310x310.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/fonts/OpenSans-Bold.ttf' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/fonts/OpenSans-Bold.ttf' '/home/borto/Github/Compiti-scolastici/_site/data/fonts/OpenSans-Bold.ttf' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/arte/etruschi/tombe/ipogeavolumni.jpg' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/arte/etruschi/tombe/ipogeavolumni.jpg' '/home/borto/Github/Compiti-scolastici/_site/data/img/arte/etruschi/tombe/ipogeavolumni.jpg' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/fonts/OpenSans-ExtraBold.ttf' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/fonts/OpenSans-ExtraBold.ttf' '/home/borto/Github/Compiti-scolastici/_site/data/fonts/OpenSans-ExtraBold.ttf' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/fonts/OpenSans-Light.ttf' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/fonts/OpenSans-Light.ttf' '/home/borto/Github/Compiti-scolastici/_site/data/fonts/OpenSans-Light.ttf' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/fonts/OpenSans-Regular.ttf' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/fonts/OpenSans-Regular.ttf' '/home/borto/Github/Compiti-scolastici/_site/data/fonts/OpenSans-Regular.ttf' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/arte/etruschi/tombe/ipogeavolumnimappa.jpg' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/arte/etruschi/tombe/ipogeavolumnimappa.jpg' '/home/borto/Github/Compiti-scolastici/_site/data/img/arte/etruschi/tombe/ipogeavolumnimappa.jpg' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/chimica/lss/acidi-e-basi/WordCloudAcido.jpg' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/chimica/lss/acidi-e-basi/WordCloudAcido.jpg' '/home/borto/Github/Compiti-scolastici/_site/data/img/chimica/lss/acidi-e-basi/WordCloudAcido.jpg' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/fonts/Title.ttf' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/fonts/Title.ttf' '/home/borto/Github/Compiti-scolastici/_site/data/fonts/Title.ttf' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/fonts/OpenSans-SemiBold.ttf' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/fonts/OpenSans-SemiBold.ttf' '/home/borto/Github/Compiti-scolastici/_site/data/fonts/OpenSans-SemiBold.ttf' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/chimica/lss/acidi-e-basi/cartina_tornasole.jpeg' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/chimica/lss/acidi-e-basi/cartina_tornasole.jpeg' '/home/borto/Github/Compiti-scolastici/_site/data/img/chimica/lss/acidi-e-basi/cartina_tornasole.jpeg' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/inglese/dinosaurs-timeline.webp' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/inglese/dinosaurs-timeline.webp' '/home/borto/Github/Compiti-scolastici/_site/data/img/inglese/dinosaurs-timeline.webp' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/latino/versioni/analisi-periodo/33-pagina-259.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/latino/versioni/analisi-periodo/33-pagina-259.png' '/home/borto/Github/Compiti-scolastici/_site/data/img/latino/versioni/analisi-periodo/33-pagina-259.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/latino/versioni/analisi-periodo/9-pagina-263.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/latino/versioni/analisi-periodo/9-pagina-263.png' '/home/borto/Github/Compiti-scolastici/_site/data/img/latino/versioni/analisi-periodo/9-pagina-263.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/latino/versioni/analisi-periodo/32-pagina-258.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/latino/versioni/analisi-periodo/32-pagina-258.png' '/home/borto/Github/Compiti-scolastici/_site/data/img/latino/versioni/analisi-periodo/32-pagina-258.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/latino/versioni/analisi-periodo/44-pagina-285.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/latino/versioni/analisi-periodo/44-pagina-285.png' '/home/borto/Github/Compiti-scolastici/_site/data/img/latino/versioni/analisi-periodo/44-pagina-285.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/LogoSitoWeb.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/LogoSitoWeb.png' '/home/borto/Github/Compiti-scolastici/_site/data/img/LogoSitoWeb.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/chimica/lss/acidi-e-basi/WordCloudBase.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/chimica/lss/acidi-e-basi/WordCloudBase.png' '/home/borto/Github/Compiti-scolastici/_site/data/img/chimica/lss/acidi-e-basi/WordCloudBase.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/grafici1to4.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/fisica/lss/moto/grafici1to4.png' '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/grafici1to4.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/grafico1.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/fisica/lss/moto/grafico1.png' '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/grafico1.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/latino/versioni/analisi-periodo/PrometheusIapetiFilius.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/latino/versioni/analisi-periodo/PrometheusIapetiFilius.png' '/home/borto/Github/Compiti-scolastici/_site/data/img/latino/versioni/analisi-periodo/PrometheusIapetiFilius.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/cso.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/cso.png' '/home/borto/Github/Compiti-scolastici/_site/data/img/cso.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/chimica/lss/acidi-e-basi/fenoftaleina.jpg' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/chimica/lss/acidi-e-basi/fenoftaleina.jpg' '/home/borto/Github/Compiti-scolastici/_site/data/img/chimica/lss/acidi-e-basi/fenoftaleina.jpg' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/arte/etruschi/tombe/tumulomontagnola.jpg' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/arte/etruschi/tombe/tumulomontagnola.jpg' '/home/borto/Github/Compiti-scolastici/_site/data/img/arte/etruschi/tombe/tumulomontagnola.jpg' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/grafico4.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/fisica/lss/moto/grafico4.png' '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/grafico4.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/grafico2.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/fisica/lss/moto/grafico2.png' '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/grafico2.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/grafico3.png' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/fisica/lss/moto/grafico3.png' '/home/borto/Github/Compiti-scolastici/_site/data/img/fisica/lss/moto/grafico3.png' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/geometria/dimostrazioni/6-866.jpg' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/geometria/dimostrazioni/6-866.jpg' '/home/borto/Github/Compiti-scolastici/_site/data/img/geometria/dimostrazioni/6-866.jpg' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/geometria/dimostrazioni/7-866.jpg' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/geometria/dimostrazioni/7-866.jpg' '/home/borto/Github/Compiti-scolastici/_site/data/img/geometria/dimostrazioni/7-866.jpg' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/chimica/lss/acidi-e-basi/provetteac.jpg' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/chimica/lss/acidi-e-basi/provetteac.jpg' '/home/borto/Github/Compiti-scolastici/_site/data/img/chimica/lss/acidi-e-basi/provetteac.jpg' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/geometria/dimostrazioni/3-866.jpg' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/geometria/dimostrazioni/3-866.jpg' '/home/borto/Github/Compiti-scolastici/_site/data/img/geometria/dimostrazioni/3-866.jpg' # duplicate

original_cmd  '/home/borto/Github/Compiti-scolastici/_site/data/img/arte/etruschi/tombe/edicolasancerbone.jpg' # original
remove_cmd    '/home/borto/Github/Compiti-scolastici/data/img/arte/etruschi/tombe/edicolasancerbone.jpg' '/home/borto/Github/Compiti-scolastici/_site/data/img/arte/etruschi/tombe/edicolasancerbone.jpg' # duplicate
                                               
                                               
                                               
######### END OF AUTOGENERATED OUTPUT #########
                                               
if [ $PROGRESS_CURR -le $PROGRESS_TOTAL ]; then
    print_progress_prefix                      
    echo "${COL_BLUE}Done!${COL_RESET}"      
fi                                             
                                               
if [ -z $DO_REMOVE ] && [ -z $DO_DRY_RUN ]     
then                                           
  echo "Deleting script " "$0"             
  rm -f '/home/borto/Github/Compiti-scolastici/rmlint.sh';                                     
fi                                             
