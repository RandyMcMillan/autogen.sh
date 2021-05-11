#!/bin/sh
#
autoreconf -vif

ln -s $(which glibtoolize) /usr/local/bin/libtoolize
set -x

# https://github.com/leleliu008/autogen.sh

cd "$(dirname "$0")" || exit 1

COLOR_RED='\033[0;31m'          # Red
COLOR_GREEN='\033[0;32m'        # Green
COLOR_YELLOW='\033[0;33m'       # Yellow
COLOR_BLUE='\033[0;34m'         # Blue
COLOR_PURPLE='\033[0;35m'       # Purple
COLOR_OFF='\033[0m'             # Reset

print() {
    printf "%b" "$*"
}

echo() {
    print "$*\n"
}

info() {
    echo "$COLOR_PURPLE==>$COLOR_OFF $COLOR_GREEN$@$COLOR_OFF"
}

success() {
    print "${COLOR_GREEN}[✔] $*\n${COLOR_OFF}"
}

warn() {
    print "${COLOR_YELLOW}🔥  $*\n${COLOR_OFF}"
}

error() {
    print "${COLOR_RED}[✘] $*\n${COLOR_OFF}"
}

die() {
    print "${COLOR_RED}[✘] $*\n${COLOR_OFF}"
    exit 1
}

# check if file exists
# $1 FILEPATH
file_exists() {
    [ -n "$1" ] && [ -e "$1" ]
}

# check if command exists
# $1 command name or path
command_exists() {
    case $1 in
        */*) executable "$1" ;;
        *)   command -v "$1" > /dev/null
    esac
}

executable() {
    file_exists "$1" && [ -x "$1" ]
}

die_if_file_is_not_exist() {
    file_exists "$1" || die "$1 is not exists."
}

die_if_not_executable() {
    executable "$1" || die "$1 is not executable."
}

step() {
    STEP_NUM=$(expr ${STEP_NUM-0} + 1)
    STEP_MESSAGE="$@"
    echo
    echo "${COLOR_PURPLE}=>> STEP ${STEP_NUM} : ${STEP_MESSAGE} ${COLOR_OFF}"
}

run() {
    info "$*"
    eval "$*"
}

list() {
    for item in $@
    do
        echo "$item"
    done
}

list_length() {
    echo $#
}

shiftn() {
    shift "$1" && shift && echo "$@"
}

sed_in_place() {
    if command -v gsed > /dev/null ; then
        run gsed -i "\"$1\"" $(shiftn 1 $@)
    elif command -v sed  > /dev/null ; then
        if sed -i 's/a/b/g' $(mktemp) 2> /dev/null ; then
            run sed -i "\"$1\"" $(shiftn 1 $@)
        else
            run sed -i '""' "\"$1\"" $(shiftn 1 $@)
        fi
    else
        die "please install sed utility."
    fi
}

getvalue() {
    if [ $# -eq 0 ] ; then
        cut -d= -f2
    else
        echo "$1" | cut -d= -f2
    fi
}

trim() {
    if [ $# -eq 0 ] ; then
        sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//'
    else
        if [ -n "$*" ] ; then
            echo "$*" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//'
        fi
    fi
}

tolower() {
    if [ $# -eq 0 ] ; then
        if command -v tr > /dev/null ; then
            tr A-Z a-z
        elif command -v  awk > /dev/null ; then
            awk '{print(tolower($0))}'
        elif command -v gawk > /dev/null ; then
            gawk '{print(tolower($0))}'
        else
            die "please install GNU CoreUtils or awk."
        fi
    else
        if [ -z "$*" ] ; then
            return 0
        fi
        if command -v tr > /dev/null ; then
            echo "$*" | tr A-Z a-z
        elif command -v  awk > /dev/null ; then
            echo "$*" | awk '{print(tolower($0))}'
        elif command -v gawk > /dev/null ; then
            echo "$*" | gawk '{print(tolower($0))}'
        elif command -v python > /dev/null ; then
            python  -c 'import sys; print(sys.argv[1].lower());' "$*"
        elif command -v python3 > /dev/null ; then
            python3 -c 'import sys; print(sys.argv[1].lower());' "$*"
        elif command -v python2 > /dev/null ; then
            python2 -c 'import sys; print(sys.argv[1].lower());' "$*"
        elif command -v perl > /dev/null ; then
            perl -e 'print @ARGV[0],"\n"' "$1"
        elif command -v node > /dev/null ; then
            node -e 'console.log(process.argv[2].toLowerCase())' - "$*"
        else
            die "please install GNU CoreUtils or awk."
        fi
    fi
}

nproc() {
    if command nproc --version > /dev/null 2>&1 ; then
        command nproc
    elif test -f /proc/cpuinfo ; then
        grep -c processor /proc/cpuinfo
    elif command -v sysctl > /dev/null ; then
        sysctl -n machdep.cpu.thread_count
    else
        echo 4
    fi
}

format_unix_timestamp() {
   date -jf "%s" "$1" "$2" 2> /dev/null ||
   date -d      "@$1" "$2"
}

# }}}
##############################################################################
# {{{ md5sum

#examples:
# printf ss | md5sum
# cat FILE  | md5sum
# md5sum < FILE
md5sum() {
    if [ $# -eq 0 ] ; then
        if   command md5sum --version > /dev/null 2>&1 ; then
             command md5sum | cut -d ' ' -f1
        elif command -v openssl > /dev/null ; then
             openssl md5 | rev | cut -d ' ' -f1 | rev
        else
            die "please install openssl or GNU CoreUtils."
        fi
    else
        if command -v openssl > /dev/null ; then
             openssl md5    "$1" | cut -d ' ' -f2
        elif command md5sum --version > /dev/null 2>&1 ; then
             command md5sum "$1" | cut -d ' ' -f1
        else
            die "please install openssl or GNU CoreUtils."
        fi
    fi
}

# }}}
##############################################################################
# {{{ sha256sum

#examples:
# printf ss | sha256sum
# cat FILE  | sha256sum
# sha256sum < FILE
sha256sum() {
    if [ $# -eq 0 ] ; then
        if   command sha256sum --version > /dev/null 2>&1 ; then
             command sha256sum | cut -d ' ' -f1
        elif command -v openssl > /dev/null ; then
             openssl sha256 | rev | cut -d ' ' -f1 | rev
        else
            die "please install openssl or GNU CoreUtils."
        fi
    else
        die_if_file_is_not_exist "$1"
        if command -v openssl > /dev/null ; then
             openssl sha256    "$1" | cut -d ' ' -f2
        elif command sha256sum --version > /dev/null 2>&1 ; then
             command sha256sum "$1" | cut -d ' ' -f1
        else
            die "please install openssl or GNU CoreUtils."
        fi
    fi
}

# $1 FILEPATH
# $2 expect sha256sum
file_exists_and_sha256sum_matched() {
    die_if_file_is_not_exist "$1"
    [ -z "$2" ] && die "please specify expected sha256sum."
    [ "$(sha256sum $1)" = "$2" ]
}

# $1 FILEPATH
# $2 expect sha256sum
die_if_sha256sum_mismatch() {
    file_exists_and_sha256sum_matched "$1" "$2" || die "sha256sum mismatch.\n    expect : $2\n    actual : $(sha256sum $1)"
}

# }}}
##############################################################################
# {{{ map

# $1 map_name
__map_name_ref() {
    die_if_map_name_is_not_specified "$1"
    printf "map_%s\n" "$(printf '%s' "$1" | md5sum)"
}

# $1 map_name
# $2 key
__map_key_ref() {
    die_if_map_name_is_not_specified   "$1"
    die_if_map_key__is_not_specified   "$2"
    printf "%s_%s\n" "$(__map_name_ref "$1")" "$(printf '%s' "$2" | md5sum)"
}

# $1 map_name
# $2 key
map_contains() {
    die_if_map_name_is_not_specified "$1"
    die_if_map_key__is_not_specified "$2"
    for item in $(eval echo \$$(__map_name_ref "$1"))
    do
        [ "$item" = "$2" ] && return 0
    done
    return 1
}

# $1 map_name
# $2 key
# $3 value
map_set() {
    die_if_map_name_is_not_specified "$1"
    die_if_map_key__is_not_specified "$2"
    if ! map_contains "$1" "$2" ; then
        unset __MAP_NAME_REF__
        __MAP_NAME_REF__="$(__map_name_ref "$1")"
        __MAP_NAME_REF_VALUE__="$(eval echo \$$__MAP_NAME_REF__)"
        eval "$__MAP_NAME_REF__=\"$__MAP_NAME_REF_VALUE__ $2\""
    fi
    eval "$(__map_key_ref "$1" "$2")=$3"
}

# $1 map_name
# $2 key
# output: value
map_get() {
    die_if_map_name_is_not_specified "$1"
    die_if_map_key__is_not_specified "$2"
    eval echo "\$$(__map_key_ref "$1" "$2")"
}

# $1 map_name
# $2 key
# output: value
map_remove() {
    die_if_map_name_is_not_specified "$1"
    die_if_map_key__is_not_specified "$2"

    unset __MAP_NAME_REF__
    __MAP_NAME_REF__="$(__map_name_ref "$1")"

    unset __MAP_KEYS__
    __MAP_KEYS__="$(map_keys "$1")"

    unset $__MAP_NAME_REF__

    for item in $__MAP_KEYS__
    do
        if [ "$item" = "$2" ] ; then
            continue
        else
            eval "$__MAP_NAME_REF__='$(eval echo \$$__MAP_NAME_REF__) $item'"
        fi
    done
    eval "unset $(__map_key_ref "$1" "$2")"
}

# $1 map_name
map_clear() {
    die_if_map_name_is_not_specified "$1"

    unset __MAP_NAME_REF__
    __MAP_NAME_REF__="$(__map_name_ref "$1")"

    for item in $(eval echo "\$$__MAP_NAME_REF__")
    do
        eval "unset $(__map_key_ref "$1" "$item")"
    done
    eval "unset $__MAP_NAME_REF__"
}

# $1 map_name
# output: key list
map_keys() {
    die_if_map_name_is_not_specified "$1"
    eval echo "\$$(__map_name_ref "$1")"
}

# $1 map_name
# output: key list length
map_size() {
    die_if_map_name_is_not_specified "$1"
    list_length $(map_keys "$1")
}

# $1 map_name
die_if_map_name_is_not_specified() {
    [ -z "$1" ] && die "please specify a map name."
}

# $1 key
die_if_map_key__is_not_specified() {
    [ -z "$1" ] && die "please specify a map key."
}

# }}}
##############################################################################
# {{{ fetch

__get_available_fetch_tool() {
    for item in curl wget http lynx aria2c axel
    do
        if command_exists "$item" ; then
            echo "$item"
            return 0
        fi
    done
    return 1
}

__fetch_via_git() {
    if [ -d "$FETCH_OUTPUT_PATH" ] ; then
        if      git -C "$FETCH_OUTPUT_PATH" rev-parse 2> /dev/null ; then
            run git -C "$FETCH_OUTPUT_PATH" pull &&
            run git -C "$FETCH_OUTPUT_PATH" submodule update --recursive
        else
            run rm -rf "$FETCH_OUTPUT_PATH" &&
            run git -C "$FETCH_OUTPUT_DIR" clone --recursive "$FETCH_URL" "$FETCH_OUTPUT_NAME"
        fi
    else
        run git -C "$FETCH_OUTPUT_DIR" clone --recursive "$FETCH_URL" "$FETCH_OUTPUT_NAME"
    fi
}

__fetch_archive_via_tools() {
    if [ -f "$FETCH_OUTPUT_PATH" ] ; then
        if [ -n "$FETCH_SHA256" ] ; then
            if file_exists_and_sha256sum_matched "$FETCH_OUTPUT_PATH" "$FETCH_SHA256" ; then
                success "$FETCH_OUTPUT_PATH eval."
                return 0
            fi
        fi
        rm -f "$FETCH_OUTPUT_PATH"
    fi

    AVAILABLE_FETCH_TOOL=$(__get_available_fetch_tool)

    if [ -z "$AVAILABLE_FETCH_TOOL" ] ; then
        handle_dependency required command curl || return 1
        if command_exists curl ; then
            AVAILABLE_FETCH_TOOL=curl
        else
            return 1
        fi
    fi

    case $AVAILABLE_FETCH_TOOL in
        curl)  run curl --fail --retry 20 --retry-delay 30 --location -o "$FETCH_OUTPUT_PATH" "\"$FETCH_URL\"" ;;
        wget)  run wget --timeout=60 -O "$FETCH_OUTPUT_PATH" "\"$FETCH_URL\"" ;;
        http)  run http --timeout=60 -o "$FETCH_OUTPUT_PATH" "\"$FETCH_URL\"" ;;
        lynx)  run lynx -source "$FETCH_URL" > "\"$FETCH_OUTPUT_PATH\"" ;;
        aria2c)run aria2c -d "$FETCH_OUTPUT_DIR" -o "$FETCH_OUTPUT_NAME" "\"$FETCH_URL\"" ;;
        axel)  run axel -o "$FETCH_OUTPUT_PATH" "\"$FETCH_URL\"" ;;
    esac

    if [ $? -eq 0 ] ; then
        success "Fetched to $FETCH_OUTPUT_PATH success."
    else
        die "Fetched to $FETCH_OUTPUT_PATH failed."
    fi

    if [ -n "$FETCH_SHA256" ] ; then
        die_if_sha256sum_mismatch "$FETCH_OUTPUT_PATH" "$FETCH_SHA256"
    fi
}

# fetch <URL> [--sha256=SHA256] <--output-path=PATH>
# fetch <URL> [--sha256=SHA256] <--output-dir=DIR> <--output-name=NAME>
# fetch <URL> [--sha256=SHA256] <--output-dir=DIR> [--output-name=NAME]
# fetch <URL> [--sha256=SHA256] [--output-dir=DIR] <--output-name=NAME>
fetch() {
    unset FETCH_URL
    unset FETCH_SHA256
    unset FETCH_OUTPUT_DIR
    unset FETCH_OUTPUT_NAME
    unset FETCH_OUTPUT_PATH

    if [ -z "$1" ] ; then
        die "please specify a fetch url."
    else
        FETCH_URL="$1"
    fi

    shift

    while [ -n "$1" ]
    do
        case $1 in
            --sha256=*)
                FETCH_SHA256=$(getvalue "$1")
                ;;
            --output-dir=*)
                FETCH_OUTPUT_DIR=$(getvalue "$1")
                if [ -z "$FETCH_OUTPUT_DIR" ] ; then
                    die "--output-dir argument's value must be not empty."
                fi
                ;;
            --output-name=*)
                FETCH_OUTPUT_NAME=$(getvalue "$1")
                if [ -z "$FETCH_OUTPUT_NAME" ] ; then
                    die "--output-name argument's value must be not empty."
                fi
                ;;
            --output-path=*)
                FETCH_OUTPUT_PATH=$(getvalue "$1")
                if [ -z "$FETCH_OUTPUT_PATH" ] ; then
                    die "--output-path argument's value must be not empty."
                fi
        esac
        shift
    done

    if [ -z "$FETCH_OUTPUT_PATH" ] ; then
        [ -z "$FETCH_OUTPUT_DIR" ]  && FETCH_OUTPUT_DIR="$PWD"
        [ -z "$FETCH_OUTPUT_NAME" ] && FETCH_OUTPUT_NAME=$(basename "$FETCH_URL")

        FETCH_OUTPUT_PATH="$FETCH_OUTPUT_DIR/$FETCH_OUTPUT_NAME"
    else
        FETCH_OUTPUT_DIR="$(dirname $FETCH_OUTPUT_PATH)"
        FETCH_OUTPUT_NAME="$(basename $FETCH_OUTPUT_PATH)"
    fi

    if [ ! -d "$FETCH_OUTPUT_DIR" ] ; then
        run install -d "$FETCH_OUTPUT_DIR"
    fi

    case $FETCH_URL in
        *.git) __fetch_via_git ;;
        *)     __fetch_archive_via_tools ;;
    esac
}

# }}}
##############################################################################
# {{{ os

__get_os_name_from_uname_a() {
    if command -v uname > /dev/null ; then
        unset V
        V=$(uname -a | cut -d ' ' -f2)
        case $V in
            opensuse*) return 1 ;;
            *-*) echo "$V" | cut -d- -f1 ;;
            *)   return 1
        esac
    else
        return 1
    fi
}

__get_os_version_from_uname_a() {
    if command -v uname > /dev/null ; then
        unset V
        V=$(uname -a | cut -d ' ' -f2)
        case $V in
            opensuse*) return 1 ;;
            *-*) echo "$V" | cut -d- -f2 ;;
            *)   return 1
        esac
    else
        return 1
    fi
}

# https://www.freedesktop.org/software/systemd/man/os-release.html
__get_os_name_from_etc_os_release() {
    if [ -f /etc/os-release ] ; then
        unset F
        F=$(mktemp) &&
        cat /etc/os-release > "$F" &&
        echo 'echo "$ID"'  >> "$F" &&
        sh "$F"
    else
        return 1
    fi
}

__get_os_version_from_etc_os_release() {
    if [ -f /etc/os-release ] ; then
        unset F
        F=$(mktemp) &&
        cat /etc/os-release > "$F" &&
        echo 'echo "$VERSION_ID"'  >> "$F" && {
            unset V
            V=$(sh "$F")
            if [ -z "$V" ] ; then
                echo 'rolling'
            else
                echo "$V"
            fi
        }
    else
        return 1
    fi
}

# https://refspecs.linuxfoundation.org/LSB_3.0.0/LSB-PDA/LSB-PDA/lsbrelease.html
__get_os_name_from_lsb_release() {
    if command -v lsb_release > /dev/null ; then
        lsb_release --id | cut -f2
    else
        return 1
    fi
}

__get_os_version_from_lsb_release() {
    if command -v lsb_release > /dev/null ; then
        lsb_release --release | cut -f2
    else
        return 1
    fi
}

__get_os_name_from_getprop() {
    if command -v getprop > /dev/null && command -v app_process > /dev/null ; then
        echo 'android'
    else
        return 1
    fi
}

__get_os_version_from_getprop() {
    if command -v getprop > /dev/null ; then
        getprop ro.build.version.release
    else
        return 1
    fi
}

__get_os_arch_from_getprop() {
    if command -v getprop > /dev/null ; then
        getprop ro.product.cpu.abi
    else
        return 1
    fi
}

__get_os_arch_from_uname() {
    if command -v uname > /dev/null ; then
        uname -m 2> /dev/null
    else
        return 1
    fi
}

__get_os_arch_from_arch() {
    if command -v arch > /dev/null ; then
        arch
    else
        return 1
    fi
}

os() {
    if [ $# -eq 0 ] ; then
        printf "current-machine-os-kind : %s\n" "$(os kind)"
        printf "current-machine-os-type : %s\n" "$(os type)"
        printf "current-machine-os-name : %s\n" "$(os name)"
        printf "current-machine-os-vers : %s\n" "$(os version)"
        printf "current-machine-os-arch : %s\n" "$(os arch)"
        printf "current-machine-os-libc : %s\n" "$(os libc)"
    elif [ $# -eq 1 ] ; then
        case $1 in
            -h|--help)
                cat <<'EOF'
os -h | --help
os -V | --version
os kind
os type
os arch
os libc
os name
os version
EOF
                ;;
            -V|--version) echo '2021.03.28.23' ;;
            kind)
                case $(uname | tr A-Z a-z) in
                    msys*)    echo "windows" ;;
                    mingw32*) echo "windows" ;;
                    mingw64*) echo "windows" ;;
                    cygwin*)  echo 'windows' ;;
                    *)  uname | tr A-Z a-z
                esac
                ;;

            type)
                case $(uname | tr A-Z a-z) in
                    msys*)    echo "msys"    ;;
                    mingw32*) echo "mingw32" ;;
                    mingw64*) echo "mingw64" ;;
                    cygwin*)  echo 'cygwin'  ;;
                    *)  uname | tr A-Z a-z
                esac
                ;;
            name)
                case $(os kind) in
                    freebsd) echo 'FreeBSD' ;;
                    openbsd) echo 'OpenBSD' ;;
                    netbsd)  echo 'NetBSD'  ;;
                    darwin)  sw_vers -productName ;;
                    linux)
                        __get_os_name_from_uname_a ||
                        __get_os_name_from_etc_os_release ||
                        __get_os_name_from_lsb_release
                        ;;
                    windows)
                        systeminfo | grep 'OS Name:' | cut -d: -f2 | head -n 1 | sed 's/^[[:space:]]*//' ;;
                    *)  uname | tr A-Z a-z
                esac
                ;;
            arch)
                __get_os_arch_from_uname ||
                __get_os_arch_from_arch  ||
                __get_os_arch_from_getprop
                ;;
            libc)
                case $(os kind) in
                    linux)
                        # https://pubs.opengroup.org/onlinepubs/7908799/xcu/getconf.html
                        if command -v getconf > /dev/null ; then
                            if getconf GNU_LIBC_VERSION > /dev/null 2>&1 ; then
                                echo glibc
                                return 0
                            fi
                        fi
                        if command -v ldd > /dev/null ; then
                            if ldd --version 2>&1 | head -n 1 | grep -q GLIBC ; then
                                echo glibc
                                return 0
                            fi
                            if ldd --version 2>&1 | head -n 1 | grep -q musl ; then
                                echo musl
                                return 0
                            fi
                        fi
                        return 1
                esac
                ;;
            version)
                case $(os kind) in
                    freebsd) freebsd-version ;;
                    openbsd) uname -r ;;
                    netbsd)  uname -r ;;
                    darwin)  sw_vers -productVersion ;;
                    linux)
                        __get_os_version_from_uname_a ||
                        __get_os_version_from_etc_os_release ||
                        __get_os_version_from_lsb_release
                        ;;
                    windows)
                        systeminfo | grep 'OS Version:' | cut -d: -f2 | head -n 1 | sed 's/^[[:space:]]*//' | cut -d ' ' -f1 ;;
                esac
                ;;
            *)  echo "$1: not support item."; return 1
        esac
    else
        echo "os command only support one item."; return 1
    fi
}

# }}}
##############################################################################
# {{{ version

version_of_python_module() {
    PIP_COMMAND=$(command -v pip3 || command -v pip)
    if [ -z "$PIP_COMMAND" ] ; then
        die "can't found pip command."
    else
        "$PIP_COMMAND" show $1 | grep 'Version:' | cut -d ' ' -f2
    fi
}

# retrive the version of a command from it's name or path
version_of_command() {
    case $(basename "$1") in
        cmake) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f3 ;;
         make) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f3 ;;
        gmake) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f3 ;;
       rustup) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
        cargo) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
           go) "$1"   version | cut -d ' ' -f3 | cut -c3- ;;
         tree) "$1" --version | cut -d ' ' -f2 | cut -c2- ;;
   pkg-config) "$1" --version 2> /dev/null | head -n 1 ;;
       m4|gm4) "$1" --version 2> /dev/null | head -n 1 | awk '{print($NF)}';;
    autopoint) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 ;;
     automake|aclocal)
               "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 ;;
     autoconf|autoheader|autom4te|autoreconf|autoscan|autoupdate|ifnames)
               "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 ;;
      libtool) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 ;;
   libtoolize|glibtoolize)
               "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 ;;
      objcopy) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f5 ;;
         flex) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
        bison) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 ;;
         yacc) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 ;;
         nasm) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f3 ;;
         yasm) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
        patch) "$1" --version 2> /dev/null | head -n 1 | awk '{print($NF)}' ;;
        gperf) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f3 ;;
        groff) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 ;;
     help2man) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f3 ;;
 sphinx-build) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
         file) "$1" --version 2> /dev/null | head -n 1 | cut -d '-' -f2 ;;
      itstool) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
       protoc) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
        xmlto) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f3 ;;
      xmllint) ;;
     xsltproc) ;;
         gzip) "$1" --version 2>&1 | head -n 1 | awk '{print($NF)}' ;;
         lzip) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
           xz) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 ;;
          zip) "$1" --version 2> /dev/null | sed -n '2p' | cut -d ' ' -f4 ;;
        unzip) "$1" -v        2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
        bzip2) "$1" --help 2>&1 | head -n 1 | cut -d ' ' -f8 | cut -d ',' -f1 ;;
          tar)
            VERSION_MSG=$("$1" --version 2> /dev/null | head -n 1)
            case $VERSION_MSG in
                  tar*) echo "$VERSION_MSG" | cut -d ' ' -f4 ;;
               bsdtar*) echo "$VERSION_MSG" | cut -d ' ' -f2 ;;
            esac
            ;;
          git) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f3 ;;
         curl) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
     awk|gawk) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f3 | tr , ' ' ;;
     sed|gsed) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 ;;
         cpan) ;;
         grep) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 | cut -d '-' -f1 ;;
         ruby) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
         perl) "$1" -v | sed -n '2p' | sed 's/.*v\([0-9]\.[0-9][0-9]\.[0-9]\).*/\1/' ;;
    python|python2|python3)
               "$1" --version 2>&1 | head -n 1 | cut -d ' ' -f2 ;;
         pip)  "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
         pip3) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
         node) "$1" --version 2> /dev/null | head -n 1 | cut -d 'v' -f2 ;;
          zsh) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
         bash) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 | cut -d '(' -f1 ;;
            *) "$1" --version 2> /dev/null | head -n 1
    esac
}

# retrive the major part of the version of the given command
# Note: the version of the given command must have form: major.minor.patch
version_major_of_command() {
    version_of_command "$1" | cut -d. -f1
}

# retrive the minor part of the version of the given command
# Note: the version of the given command must have form: major.minor.patch
version_minor_of_command() {
    version_of_command "$1" | cut -d. -f2
}

# retrive the major part of the given version
# Note: the given version must have form: major.minor.patch
version_major_of_version() {
    echo "$1" | cut -d. -f1
}

# retrive the minor part of the given version
# Note: the given version must have form: major.minor.patch
version_minor_of_version() {
    echo "$1" | cut -d. -f2
}

version_sort() {
    # https://pubs.opengroup.org/onlinepubs/9699919799/utilities/sort.html
    # https://man.netbsd.org/NetBSD-8.1/i386/sort.1
    #
    # sort: unrecognized option: V
    # BusyBox v1.29.3 (2019-01-24 07:45:07 UTC) multi-call binary.
    # Usage: sort [-nrugMcszbdfiokt] [-o FILE] [-k start[.offset][opts][,end[.offset][opts]] [-t CHAR] [FILE]...
    if  echo | (sort -V 2> /dev/null) ; then
        echo "$@" | tr ' ' '\n' | sort -V
    else
        echo "$@" | tr ' ' '\n' | sort -t. -n -k1,1 -k2,2 -k3,3 -k4,4
    fi
}

# check if match the condition
#
# condition:
# eq  equal
# ne  not equal
# gt  greater than
# lt  less than
# ge  greater than or equal
# le  less than or equal
#
# examples:
# version_match 1.15.3 eq 1.16.0
# version_match 1.15.3 lt 1.16.0
# version_match 1.15.3 gt 1.16.0
# version_match 1.15.3 le 1.16.0
# version_match 1.15.3 ge 1.16.0
version_match() {
    case $2 in
        eq)  [ "$1"  = "$3" ] ;;
        ne)  [ "$1" != "$3" ] ;;
        le)
            [ "$1" = "$3" ] && return 0
            [ "$1" = $(version_sort "$1" "$3" | head -n 1) ]
            ;;
        ge)
            [ "$1" = "$3" ] && return 0
            [ "$1" = $(version_sort "$1" "$3" | tail -n 1) ]
            ;;
        lt)
            [ "$1" = "$3" ] && return 1
            [ "$1" = $(version_sort "$1" "$3" | head -n 1) ]
            ;;
        gt)
            [ "$1" = "$3" ] && return 1
            [ "$1" = $(version_sort "$1" "$3" | tail -n 1) ]
            ;;
        *)  die "version_compare: $2: not supported operator."
    esac
}

# check if the version of give installed command match the condition
#
# condition:
# eq  equal
# ne  not equal
# gt  greater than
# lt  less than
# ge  greater than or equal
# le  less than or equal
#
# examples:
# command_exists_and_version_matched automake eq 1.16.0
# command_exists_and_version_matched automake lt 1.16.0
# command_exists_and_version_matched automake gt 1.16.0
# command_exists_and_version_matched automake le 1.16.0
# command_exists_and_version_matched automake ge 1.16.0
# command_exists_and_version_matched automake
command_exists_and_version_matched() {
    if command_exists "$1" ; then
        if [ "$NATIVE_OS_TYPE" = 'cygwin' ] ; then
            case $(command -v "$1") in
                /cygdrive/*) return 1
            esac
        fi
        if [ $# -eq 3 ] ; then
            version_match "$(version_of_command "$1")" "$2" "$3"
        fi
    else
        return 1
    fi
}

# }}}
##############################################################################
# {{{ get_XX_package_name_by_command_name

# https://cygwin.com/packages/package_list.html
get_choco_package_name_by_command_name() {
    case $1 in
      cc|gcc) echo 'gcc-g++' ;;
       gmake) echo 'make' ;;
         gm4) echo 'm4'    ;;
        gsed) echo 'gnu-sed'  ;;
     objcopy) echo 'binutils' ;;
      protoc) echo 'protobuf' ;;
      ps2pdf) echo "ghostscript" ;;
    sphinx-build) echo 'python38-sphinx' ;;
    glibtool|libtoolize|glibtoolize)
                echo "libtool"  ;;
    autoreconf) echo "autoconf" ;;
    autoheader) echo "automake" ;;
    autopoint)  echo "gettext"  ;;
        *)      echo "$1"
    esac
}

get_pkg_add_package_name_by_command_name() {
    case $1 in
          cc) echo 'gcc'   ;;
         gm4) echo 'm4'    ;;
        make) echo 'gmake' ;;
        perl) echo 'perl5' ;;
       gperf) echo 'gperf' ;;
        gsed) echo 'gnu-sed'  ;;
     objcopy) echo 'binutils' ;;
      protoc) echo 'protobuf' ;;
      ps2pdf) echo "ghostscript" ;;
    libtool|libtoolize|glibtool|glibtoolize)
              echo "libtool" ;;
    autoreconf|autoconf)
              echo "autoconf-2.69p3" ;;
    autoreconf-2.69|autoconf-2.69)
              echo "autoconf-2.69p3" ;;
    automake|autoheader)
              echo "automake-1.16.2" ;;
    automake-1.16|autoheader-1.16)
              echo "automake-1.16.2" ;;
    autopoint) echo "gettext" ;;
    pkg-config) echo "pkgconf" ;;
        *) echo "$1"
    esac
}

get_pkgin_package_name_by_command_name() {
    case $1 in
          cc) echo 'gcc'   ;;
         gm4) echo 'm4'    ;;
        make) echo 'gmake' ;;
        perl) echo 'perl5' ;;
        gsed) echo 'gnu-sed'  ;;
     objcopy) echo 'binutils' ;;
      protoc) echo 'protobuf' ;;
      ps2pdf) echo "ghostscript" ;;
    glibtool|libtoolize|glibtoolize)
                echo "libtool"  ;;
    autoreconf) echo "autoconf" ;;
    autoheader) echo "automake" ;;
    autopoint)  echo "gettext"  ;;
    pkg-config) echo "pkgconf"  ;;
        *)      echo "$1"
    esac
}

get_pkg_package_name_by_command_name() {
    case $1 in
          cc) echo 'gcc'   ;;
         gm4) echo 'm4'    ;;
        make) echo 'gmake' ;;
        perl) echo 'perl5' ;;
        gsed) echo 'gnu-sed'  ;;
     objcopy) echo 'binutils' ;;
      protoc) echo 'protobuf' ;;
      ps2pdf) echo "ghostscript" ;;
    libtool|libtoolize|glibtool|glibtoolize)
                echo "libtool"  ;;
    autoreconf) echo "autoconf" ;;
    autoheader) echo "automake" ;;
    autopoint)  echo "gettext"  ;;
    pkg-config) echo "pkgconf"  ;;
        *)      echo "$1"
    esac
}

get_emerge_package_name_by_command_name() {
    case $1 in
          cc) echo 'gcc' ;;
         gm4) echo 'm4'    ;;
        gsed) echo 'gnu-sed'  ;;
     objcopy) echo 'binutils' ;;
      protoc) echo 'protobuf' ;;
      ps2pdf) echo "ghostscript" ;;
    sphinx-build) echo "sphinx" ;;
    libtool|libtoolize|glibtool|glibtoolize)
                echo "libtool"  ;;
    autoreconf) echo "autoconf" ;;
    autoheader) echo "automake" ;;
    autopoint)  echo "gettext"  ;;
    pkg-config) echo "pkgconf"  ;;
        *)      echo "$1"
    esac
}

__get_pacman_package_name_by_command_name() {
    case $1 in
          cc|gcc)
            case $NATIVE_OS_TYPE in
                mingw32|mingw64) echo 'toolchain' ;;
                *)               echo 'gcc'
            esac
            ;;
         gm4) echo 'm4'       ;;
        gsed) echo 'gnu-sed'  ;;
     objcopy) echo 'binutils' ;;
      protoc) echo 'protobuf' ;;
      ps2pdf) echo "ghostscript" ;;
    sphinx-build) echo "python-sphinx" ;;
    libtool|libtoolize|glibtool|glibtoolize)
                echo "libtool"  ;;
    autoreconf) echo "autoconf" ;;
    autoheader) echo "automake" ;;
    autopoint)  echo "gettext"  ;;
    pkg-config) echo "pkgconf"  ;;
        *)      echo "$1"
    esac
}

__mingw_w64_i686() {
    if pacman -S -i "mingw-w64-i686-$1" > /dev/null 2>&1 ; then
        echo "mingw-w64-i686-$1"
    else
        echo "$1"
    fi
}

__mingw_w64_x86_64() {
    if pacman -S -i "mingw-w64-x86_64-$1" > /dev/null 2>&1 ; then
        echo "mingw-w64-x86_64-$1"
    else
        echo "$1"
    fi
}

get_pacman_package_name_by_command_name() {
    if [ "$1" = 'make' ] || [ "$1" = 'gmake' ] ; then
        echo make
    fi
    case $NATIVE_OS_TYPE in
        mingw32) __mingw_w64_i686   $(__get_pacman_package_name_by_command_name "$1") ;;
        mingw64) __mingw_w64_x86_64 $(__get_pacman_package_name_by_command_name "$1") ;;
        *) __get_pacman_package_name_by_command_name "$1"
    esac
}

get_xbps_package_name_by_command_name() {
    case $1 in
      cc|gcc) echo 'gcc' ;;
         gm4) echo 'm4'    ;;
       gperf) echo 'gperf' ;;
        gsed) echo 'gnu-sed'  ;;
     objcopy) echo 'binutils' ;;
      protoc) echo 'protobuf' ;;
      ps2pdf) echo "ghostscript" ;;
    glibtool|libtoolize|glibtoolize)
                echo "libtool"  ;;
    autoreconf) echo "autoconf" ;;
    autoheader) echo "automake" ;;
    autopoint)  echo "gettext"  ;;
    pkg-config) echo "pkgconf"  ;;
        *)      echo "$1"
    esac
}

get_apk_package_name_by_command_name() {
    case $1 in
      cc|gcc) echo 'gcc libc-dev' ;;
         gm4) echo 'm4'    ;;
       gperf) echo 'gperf' ;;
        gsed) echo 'gnu-sed'  ;;
     objcopy) echo 'binutils' ;;
      protoc) echo 'protobuf' ;;
      ps2pdf) echo "ghostscript" ;;
    sphinx-build) echo "sphinx" ;;
    glibtool|libtoolize|glibtoolize)
                echo "libtool"  ;;
    autoreconf) echo "autoconf" ;;
    autoheader) echo "automake" ;;
    autopoint)  echo "gettext"  ;;
    pkg-config) echo "pkgconf"  ;;
        *) echo "$1"
    esac
}

get_zypper_package_name_by_command_name() {
    case $1 in
      cc|gcc) echo 'gcc' ;;
         gm4) echo 'm4'    ;;
       gperf) echo 'gperf' ;;
        gsed) echo 'gnu-sed'  ;;
     objcopy) echo 'binutils' ;;
      protoc) echo 'protobuf' ;;
      ps2pdf) echo "ghostscript" ;;
    sphinx-build) echo "python3-Sphinx" ;;
    glibtool|libtoolize|glibtoolize)
                echo "libtool"  ;;
    autoreconf) echo "autoconf" ;;
    autoheader) echo "automake" ;;
    autopoint)  echo "gettext"  ;;
    autopoint)  echo "gettext"  ;;
        *)      echo "$1"
    esac
}

get_dnf_package_name_by_command_name() {
    case $1 in
      cc|gcc) echo 'gcc' ;;
         gm4) echo 'm4'    ;;
       gperf) echo 'gperf' ;;
        gsed) echo 'gnu-sed'  ;;
     objcopy) echo 'binutils' ;;
      protoc) echo 'protobuf' ;;
      ps2pdf) echo "ghostscript" ;;
    sphinx-build) echo "python-sphinx" ;;
    glibtool|libtoolize|glibtoolize)
                echo "libtool"  ;;
    autoreconf) echo "autoconf" ;;
    autoheader) echo "automake" ;;
    autopoint)  echo "gettext"  ;;
        *)      echo "$1"
    esac
}

get_yum_package_name_by_command_name() {
    case $1 in
      cc|gcc) echo 'gcc' ;;
         gm4) echo 'm4'    ;;
       gperf) echo 'gperf' ;;
        gsed) echo 'gnu-sed'  ;;
     objcopy) echo 'binutils' ;;
      protoc) echo 'protobuf' ;;
      ps2pdf) echo "ghostscript" ;;
    sphinx-build) echo "python-sphinx" ;;
    glibtool|libtoolize|glibtoolize)
                echo "libtool"  ;;
    autoreconf) echo "autoconf" ;;
    autoheader) echo "automake" ;;
    autopoint)  echo "gettext"  ;;
        *)      echo "$1"
    esac
}

get_apt_get_package_name_by_command_name() {
    get_apt_package_name_by_command_name $@
}

get_apt_package_name_by_command_name() {
    case $1 in
      cc|gcc) echo 'gcc' ;;
         gm4) echo 'm4'    ;;
       gperf) echo 'gperf' ;;
        gsed) echo 'gnu-sed'  ;;
     objcopy) echo 'binutils' ;;
      protoc) echo 'protobuf' ;;
      ps2pdf) echo "ghostscript" ;;
    sphinx-build) echo "python3-sphinx" ;;
    glibtool|libtoolize|glibtoolize)
                echo "libtool"  ;;
    autoreconf) echo "autoconf" ;;
    autoheader) echo "automake" ;;
    autopoint)  echo "gettext"  ;;
        *)      echo "$1"
    esac
}

get_brew_package_name_by_command_name() {
    case $1 in
      cc|gcc) echo 'gcc' ;;
         gm4) echo 'm4'    ;;
       gperf) echo 'gperf' ;;
        gsed) echo 'gnu-sed'  ;;
     objcopy) echo 'binutils' ;;
      protoc) echo 'protobuf' ;;
      ps2pdf) echo "ghostscript" ;;
    sphinx-build) echo "sphinx-doc" ;;
    glibtool|libtoolize|glibtoolize)
                echo "libtool"  ;;
    autoreconf) echo "autoconf" ;;
    autoheader) echo "automake" ;;
    autopoint)  echo "gettext"  ;;
        *)      echo "$1"
    esac
}

get_pip3_package_name_by_command_name() {
    get_pip_package_name_by_command_name $@
}

get_pip_package_name_by_command_name() {
    case $1 in
        sphinx-build) echo "sphinx" ;;
    esac
}

# }}}
##############################################################################
# {{{ __get_available_package_manager_list

__add_available_package_manager() {
    if command_exists "$1" ; then
        if [ -z "$AVAILABLE_PACKAGE_MANAGER_LIST" ] ; then
            AVAILABLE_PACKAGE_MANAGER_LIST="$2"
        else
            AVAILABLE_PACKAGE_MANAGER_LIST="$AVAILABLE_PACKAGE_MANAGER_LIST $2"
        fi
    fi
}

__get_available_package_manager_list() {
    if [ -z "$AVAILABLE_PACKAGE_MANAGER_LIST" ] ; then
        for item in brew pip3 pip apt-get apt dnf yum zypper apk xbps-install emerge pacman choco pkg pkgin pkg_add
        do
            case $item in
                apt)
                    if apt show apt > /dev/null 2>&1 ; then
                        __add_available_package_manager apt apt
                    fi
                    ;;
                xbps-install)
                    __add_available_package_manager xbps-install xbps
                    ;;
                *)  __add_available_package_manager "$item" "$item"
            esac
        done
    fi
    echo "$AVAILABLE_PACKAGE_MANAGER_LIST"
}

# }}}
##############################################################################
# {{{ __install_required

# $1 package manager name
# $2 package name
__install_package_via_package_manager() {
    case $1 in
        pip3)    run pip3 install -U "$2" ;;
        pip)     run pip  install -U "$2" ;;
        pkg)     run $sudo pkg install -y "$2" ;;
        pkgin)   run $sudo pkgin -y install "$2" ;;
        pkg_add) run $sudo pkg_add "$2" ;;
        brew)    run brew install "$2" ;;
        apt)     run $sudo apt     -y install "$2" ;;
        apt-get) run $sudo apt-get -y install "$2" ;;
        dnf)
            # Error: GPG check FAILED
            if [ "$NATIVE_OS_NAME" = 'fedora' ] && [ "$NATIVE_OS_VERS" = 'rawhide' ] ; then
                 run $sudo dnf -y install "$2" --nogpgcheck
            else
                 run $sudo dnf -y install "$2"
            fi
            ;;
        yum)     run $sudo yum -y install "$2" ;;
        zypper)  run $sudo zypper install -y "$2" ;;
        apk)     run $sudo apk add "$2" ;;
        xbps)    run $sudo xbps-install -Sy "$2" ;;
        emerge)  run $sudo emerge "$2" ;;
        pacman)  run $sudo pacman -Syy --noconfirm && run $sudo pacman -S --noconfirm "$2" ;;
        choco)   run choco install -y --source cygwin "$2" ;;
    esac
}

# $1 package manager name
# $2 command name
__install_command_via_package_manager() {
    PACKAGE_NAME="$(eval get_$(echo "$1" | tr - _)_package_name_by_command_name $2)"
    if [ -z "$PACKAGE_NAME" ] ; then
        warn "can not found a package in $1 repo, which contains the $2 command."
        return 1
    else
        print "🔥  ${COLOR_YELLOW}required command${COLOR_OFF} ${COLOR_GREEN}$(shiftn 1 $@)${COLOR_OFF}${COLOR_YELLOW}, but${COLOR_OFF} ${COLOR_GREEN}$2${COLOR_OFF} ${COLOR_YELLOW}command not found, try to install it via${COLOR_OFF} ${COLOR_GREEN}$1${COLOR_OFF}\n"
        if __install_package_via_package_manager "$1" "$PACKAGE_NAME" ; then
            echo
        else
            return 1
        fi
    fi
}

# examples:
# pkg-config ge 0.18
# python3    ge 3.5
# make
__install_command_via_available_package_manager() {
    if command_exists_and_version_matched $@ ; then
        return 0
    else
        if [ -z "$AVAILABLE_PACKAGE_MANAGER_LIST" ] ; then
            AVAILABLE_PACKAGE_MANAGER_LIST=$(__get_available_package_manager_list)
            if [ -z "$AVAILABLE_PACKAGE_MANAGER_LIST" ] ; then
                warn "no package manager found."
                return 1
            else
                echo "    Found $(list_length $AVAILABLE_PACKAGE_MANAGER_LIST) package manager : ${COLOR_GREEN}$AVAILABLE_PACKAGE_MANAGER_LIST${COLOR_OFF}"
            fi
        fi
        for pm in $AVAILABLE_PACKAGE_MANAGER_LIST
        do
            __install_command_via_package_manager "$pm" $@ && return 0
        done
    fi
}

# examples:
# URL pkg-config ge 0.18
# URL python3    ge 3.5
# URL make
__install_command_via_fetch_prebuild_binary() {
    print "🔥  ${COLOR_YELLOW}required command${COLOR_OFF} ${COLOR_GREEN}$(shiftn 1 $@)${COLOR_OFF}${COLOR_YELLOW}, but${COLOR_OFF} ${COLOR_GREEN}$2${COLOR_OFF} ${COLOR_YELLOW}command not found, try to install it via${COLOR_OFF} ${COLOR_GREEN}fetch prebuild binary${COLOR_OFF}\n"

    unset PREBUILD_BINARY_FILENAME
    unset PREBUILD_BINARY_FILEPATH

    PREBUILD_BINARY_FILENAME=$(basename "$1")
    PREBUILD_BINARY_FILEPATH="$PREBUILD_BINARY_CACHED_DIR/$PREBUILD_BINARY_FILENAME"

    if [ -d    "$PREBUILD_BINARY_UNPACK_DIR/$2" ] ; then
        rm -rf "$PREBUILD_BINARY_UNPACK_DIR/$2" || return 1
    fi

    if [ ! -f "$PREBUILD_BINARY_FILEPATH" ] ; then
        run fetch "$1" --output-dir="$PREBUILD_BINARY_CACHED_DIR" --output-name="$PREBUILD_BINARY_FILENAME" || return 1
    fi

    run install -d "$PREBUILD_BINARY_UNPACK_DIR/$2" || return 1

    case $1 in
        *.zip)
            handle_dependency required command unzip &&
            run unzip "$PREBUILD_BINARY_FILEPATH" -d "$PREBUILD_BINARY_UNPACK_DIR/$2"
            ;;
        *.tar.xz)
            handle_dependency required command tar  &&
            handle_dependency required command xz   &&
            run tar xf "$PREBUILD_BINARY_FILEPATH" -C "$PREBUILD_BINARY_UNPACK_DIR/$2" --strip-components 1
            ;;
        *.tar.gz)
            handle_dependency required command tar  &&
            handle_dependency required command gzip &&
            run tar xf "$PREBUILD_BINARY_FILEPATH" -C "$PREBUILD_BINARY_UNPACK_DIR/$2" --strip-components 1
            ;;
        *.tar.lz)
            handle_dependency required command tar  &&
            handle_dependency required command lzip &&
            run tar xf "$PREBUILD_BINARY_FILEPATH" -C "$PREBUILD_BINARY_UNPACK_DIR/$2" --strip-components 1
            ;;
        *.tar.bz2)
            handle_dependency required command tar   &&
            handle_dependency required command bzip2 &&
            run tar xf "$PREBUILD_BINARY_FILEPATH" -C "$PREBUILD_BINARY_UNPACK_DIR/$2" --strip-components 1
            ;;
        *.tgz)
            handle_dependency required command tar  &&
            handle_dependency required command gzip &&
            run tar xf "$PREBUILD_BINARY_FILEPATH" -C "$PREBUILD_BINARY_UNPACK_DIR/$2" --strip-components 1
            ;;
        *.txz)
            handle_dependency required command tar &&
            handle_dependency required command xz  &&
            run tar xf "$PREBUILD_BINARY_FILEPATH" -C "$PREBUILD_BINARY_UNPACK_DIR/$2" --strip-components 1
    esac

    if [ -d "$PREBUILD_BINARY_UNPACK_DIR/$2/bin" ] ; then
        export PATH="$PREBUILD_BINARY_UNPACK_DIR/$2/bin:$PATH"
    fi
    if [ "$NATIVE_OS_KIND" = 'darwin' ] ; then
        for item in $(find "$PREBUILD_BINARY_UNPACK_DIR" -d 4 -type d -name bin)
        do
            export PATH="$item:$PATH"
        done
    fi
}

# examples:
# pkg-config ge 0.18
# python3    ge 3.5
# make
__get_prebuild_binary_fetch_url_by_command_name() {
    case $1 in
        cmake)
            case $NATIVE_OS_KIND in
                linux)
                    if [ "$NATIVE_OS_LIBC" = 'glibc' ] ; then
                        # https://cmake.org/download
                        echo "https://github.com/Kitware/CMake/releases/download/v3.20.2/cmake-3.20.2-linux-x86_64.tar.gz"
                    fi
                    ;;
                darwin)
                    if ! command_exists brew ; then
                        echo "https://github.com/Kitware/CMake/releases/download/v3.20.2/cmake-3.20.2-macos-universal.tar.gz"
                    fi
            esac
    esac
}

# examples:
# pkg-config ge 0.18
# python3    ge 3.5
# make
__install_command() {
    if command_exists_and_version_matched $@ ; then
        return 0
    else
        unset PREBUILD_BINARY_FETCH_URL
        PREBUILD_BINARY_FETCH_URL=$(__get_prebuild_binary_fetch_url_by_command_name "$1")
        if [ -z "$PREBUILD_BINARY_FETCH_URL" ] ; then
            __install_command_via_available_package_manager $@
        else
            __install_command_via_fetch_prebuild_binary "$PREBUILD_BINARY_FETCH_URL" $@
        fi
    fi
}

# examples:
# handle_dependency required command pkg-config ge 0.18
# handle_dependency required command python     ge 3.5
# handle_dependency required python  libxml2    ge 2.19
#
# handle_dependency optional command pkg-config ge 0.18
# handle_dependency optional command python     ge 3.5
# handle_dependency optional python  libxml2    ge 2.19
handle_dependency() {
    if [ "$1" != 'required' ] ; then
        return 0
    fi

    shift

    case $1 in
        command)
            shift
            case $1 in
                *:*)
                    for item in $(echo "$1" | tr ':' ' ')
                    do
                        if command_exists_and_version_matched "$item" $2 $3 ; then
                            map_set "$MAP_REQUIRED_DEPENDENCIES" "$1" "$item"
                            return 0
                        fi
                    done
                    for item in $(echo "$1" | tr ':' ' ')
                    do
                        if __install_command "$item" $2 $3 ; then
                            map_set "$MAP_REQUIRED_DEPENDENCIES" "$1" "$item"
                            return 0
                        fi
                    done
                    ;;
                *)  __install_command $@
            esac
            ;;
        python|python3)
            shift
            if command_exists python3 ; then
                if ! python3 -c "import $1" 2> /dev/null ; then
                    if command_exists pip3 ; then
                        pip3 install -U "$1" || return 1
                    fi
                fi
            elif command_exists python ; then
                if ! python -c "import $1" 2> /dev/null ; then
                    if command_exists pip ; then
                        pip install -U "$1" || return 1
                    fi
                fi
            fi
            ;;
        perl)
            shift
            if ! perl -M"$1" -le 'print "installed"' > /dev/null 2>&1 ; then
                cpan -i "$1" || return 1
            fi
            ;;
        *) die "$1 not support."
    esac
}

__handle_required_dependencies() {
    step "handle required dependencies"

    for item in $REQUIRED_DEPENDENCY_LIST
    do
        handle_dependency $(__decode_dependency "$item") || return 1
    done
}

# }}}
##############################################################################
# {{{ __printf_dependencies

# examples:
# __printf_dependency required command pkg-config ge 0.18
# __printf_dependency required command python     ge 3.5
# __printf_dependency required python  libxml2    ge 2.19
#
# __printf_dependency optional command pkg-config ge 0.18
# __printf_dependency optional command python     ge 3.5
# __printf_dependency optional python  libxml2    ge 2.19
__printf_dependency() {
    printf "%-7s %-15s %-2s %-10s %-10s %s\n" "$1" "$2" "$3" "$4" "$5" "$6"
}

# examples:
# printf_dependency required command pkg-config ge 0.18
# printf_dependency required command python     ge 3.5
# printf_dependency required python  libxml2    ge 2.19
#
# printf_dependency optional command pkg-config ge 0.18
# printf_dependency optional command python     ge 3.5
# printf_dependency optional python  libxml2    ge 2.19
printf_dependency() {
    case $2 in
        command)
            case $3 in
                *:*)
                    if [ "$1" = 'required' ] ; then
                        REQUIRED_ITEM="$(map_get "MAP_REQUIRED_DEPENDENCIES" "$3")"
                        __printf_dependency "$2" "$REQUIRED_ITEM" "$4" "$5" "$(version_of_command $REQUIRED_ITEM)" "$(command -v $REQUIRED_ITEM)"
                    else
                        for item in $(echo "$3" | tr ':' ' ')
                        do
                            __printf_dependency "$2" "$item" "$4" "$5" "$(version_of_command $item)" "$(command -v $item)"
                        done
                    fi
                    ;;
                *)  __printf_dependency "$2" "$3" "$4" "$5" "$(version_of_command $3)" "$(command -v $3)"
            esac
            ;;
        python)
            __printf_dependency "$2" "$3" "$4" "$5" "$(version_of_python_module $3)" "$(location_of_python_module $3)"
            ;;
        perl)
            __printf_dependency "$2" "$3" "$4" "$5" "" ""
            ;;
        *)  die "$2: type not support."
    esac
}

__printf_required_dependencies() {
    step "printf required dependencies"
    if [ -z "$REQUIRED_DEPENDENCY_LIST" ] ; then
        warn "no required dependencies."
    else
        __printf_dependency TYPE NAME OP EXPECT ACTUAL LOCATION
        for item in $REQUIRED_DEPENDENCY_LIST
        do
            printf_dependency $(__decode_dependency "$item")
        done
    fi
}

__printf_optional_dependencies() {
    step "printf optional dependencies"
    if [ -z "$OPTIONAL_DEPENDENCY_LIST" ] ; then
        warn "no optional dependencies."
    else
        __printf_dependency TYPE NAME OP EXPECT ACTUAL LOCATION
        for item in $OPTIONAL_DEPENDENCY_LIST
        do
            printf_dependency $(__decode_dependency "$item")
        done
    fi
}

# }}}
##############################################################################
# {{{ location_of_python_module

location_of_python_module() {
    PIP_COMMAND=$(command -v pip3 || command -v pip)
    if [ -z "$PIP_COMMAND" ] ; then
        die "can't found pip command."
    else
        "$PIP_COMMAND" show $1 | grep 'Location:' | cut -d ' ' -f2
    fi
}

# }}}
##############################################################################
# {{{ encode/decode dependency

__encode_dependency() {
    if [ $# -eq 0 ] ; then
        tr ' ' '|'
    else
        printf "%s" "$*" | tr ' ' '|'
    fi
}

__decode_dependency() {
    if [ $# -eq 0 ] ; then
        tr '|' ' '
    else
        printf "%s" "$*" | tr '|' ' '
    fi
}

# }}}
##############################################################################
# {{{ regist dependency

# regist dependency
#
# required this is a required dependency
# optional this is a optional dependency
#
# command  this dependency is a command
# python   this dependency is a python  module
# python2  this dependency is a python2 module
# python3  this dependency is a python3 module
# perl     this dependency is a perl module
#
# gt VERSION
# ge VERSION
# lt VERSION
# le VERSION
# eq VERSION
# ne VERSION
#
# examples:
# regist_dependency required command pkg-config ge 0.18
# regist_dependency required command python     ge 3.5
# regist_dependency required python  libxml2    ge 2.19
#
# regist_dependency optional command pkg-config ge 0.18
# regist_dependency optional command python     ge 3.5
# regist_dependency optional python  libxml2    ge 2.19
regist_dependency() {
    for item in $@
    do
        case $item in
            required)
                if [ -z "$REQUIRED_DEPENDENCY_LIST" ] ; then
                    REQUIRED_DEPENDENCY_LIST="$(__encode_dependency "$*")"
                else
                    REQUIRED_DEPENDENCY_LIST="$REQUIRED_DEPENDENCY_LIST $(__encode_dependency "$*")"
                fi
                break
                ;;
            optional)
                if [ -z "$OPTIONAL_DEPENDENCY_LIST" ] ; then
                    OPTIONAL_DEPENDENCY_LIST=$(__encode_dependency "$*")
                else
                    OPTIONAL_DEPENDENCY_LIST="$OPTIONAL_DEPENDENCY_LIST $(__encode_dependency "$*")"
                fi
                break
        esac
    done
}

# }}}
##############################################################################
# {{{ __is_libtool_used

__is_libtool_used() {
    # https://www.gnu.org/software/libtool/manual/html_node/LT_005fINIT.html
    grep 'LT_INIT\s*('     configure.ac ||
    grep 'AC_PROG_LIBTOOL' configure.ac ||
    grep 'AM_PROG_LIBTOOL' configure.ac
}

# }}}
##############################################################################
# {{{ gen_config

gen_config_pre() {
    step "gen config pre"
    warn "do nothing, you can overide this function to do whatever you want."
}

gen_config() {
    step "gen config"
    run autoreconf -ivf
}

gen_config_post() {
    step "gen config post"
    warn "do nothing, you can overide this function to do whatever you want."
}

# }}}
##############################################################################
# {{{ main

main() {
    echo "${COLOR_GREEN}autogen.sh is a POSIX shell script to manage GNU Autotools(autoconf automake) and other softwares used by this project.${COLOR_OFF}"

    case $1 in
        -h|--help)
            cat <<EOF
Usage:
./autogen.sh -h | --help
./autogen.sh -V | --version
./autogen.sh [ --rc-file=FILE | -x | -d ]
EOF
            return 0
            ;;
        -V|--version) echo '1.0.0' ; return 0 ;;
    esac

    unset DEBUG

    unset STEP_NUM
    unset STEP_MESSAGE

    unset REQUIRED_DEPENDENCY_LIST
    unset OPTIONAL_DEPENDENCY_LIST

    unset PROJECT_DIR
    unset PROJECT_NAME
    unset PROJECT_VERSION

    unset NATIVE_OS_KIND
    unset NATIVE_OS_TYPE
    unset NATIVE_OS_NAME
    unset NATIVE_OS_VERS
    unset NATIVE_OS_ARCH
    unset NATIVE_OS_LIBC

    unset AUTOCONF_VERSION_MREQUIRED

    unset MAP_REQUIRED_DEPENDENCIES
    MAP_REQUIRED_DEPENDENCIES='MAP_REQUIRED_DEPENDENCIES'

    unset RC_FILE

    case $1 in
        '') ;;
        -x|-d|--rc-file=*)
            for item in $@
            do
                case $item in
                    -x) set -x ;;
                    -d) DEBUG=true ;;
                    --rc-file=*)
                        RC_FILE=$(echo "$item" | cut -d= -f2)
                        if [ -z "$RC_FILE" ] ; then
                            die "--rc-file=FILE FILE must not empty."
                        else
                            if ! file_exists "$RC_FILE" ; then
                                die "$item: file not exists."
                            fi
                        fi
                        ;;
                    *)  die "$item: not support argument."
                esac
            done
            ;;
        *)  die "$1: not support argument."
    esac

    [ -z "$RC_FILE" ] && RC_FILE='./autogen.rc'

    step "show current machine os info"
    NATIVE_OS_KIND=$(os kind)
    NATIVE_OS_TYPE=$(os type)
    NATIVE_OS_NAME=$(os name)
    NATIVE_OS_VERS=$(os version)
    NATIVE_OS_ARCH=$(os arch)
    NATIVE_OS_LIBC=$(os libc)
    echo "NATIVE_OS_KIND  = $NATIVE_OS_KIND"
    echo "NATIVE_OS_TYPE  = $NATIVE_OS_TYPE"
    echo "NATIVE_OS_NAME  = $NATIVE_OS_NAME"
    echo "NATIVE_OS_VERS  = $NATIVE_OS_VERS"
    echo "NATIVE_OS_ARCH  = $NATIVE_OS_ARCH"
    echo "NATIVE_OS_LIBC  = $NATIVE_OS_LIBC"

    # https://www.openbsd.org/faq/ports/specialtopics.html
    if [ "$NATIVE_OS_KIND" = 'openbsd' ] ; then
        [ -z "$AUTOCONF_VERSION" ] || export AUTOCONF_VERSION='2.69'
        [ -z "$AUTOMAKE_VERSION" ] || export AUTOMAKE_VERSION='1.16'

        echo
        echo "export AUTOCONF_VERSION=$AUTOCONF_VERSION"
        echo "export AUTOMAKE_VERSION=$AUTOMAKE_VERSION"

        regist_dependency required command autoconf-$AUTOCONF_VERSION ge "$AUTOCONF_VERSION_MREQUIRED"
        regist_dependency required command automake-$AUTOMAKE_VERSION
    fi

    if [ "$NATIVE_OS_KIND" != 'windows' ] ; then
        [ "$(whoami)" = root ] || sudo=sudo
    fi

    step "show current machine os effective user info"
    id | tr ' ' '\n' | head -n 2

    step "show project info"

    die_if_file_is_not_exist configure.ac

    PROJECT_DIR="$PWD"

    # https://www.gnu.org/software/autoconf/manual/autoconf-2.69/html_node/Initializing-configure.html
    PROJECT_NAME=$(grep 'AC_INIT\s*(\[.*' configure.ac | sed 's/AC_INIT\s*(\[\(.*\)\],.*/\1/')
    PROJECT_VERSION=$(grep 'AC_INIT\s*(\[.*' configure.ac | sed "s/AC_INIT\s*(\[$PROJECT_NAME\],\[\(.*\)\].*/\1/")

    echo "PROJECT_DIR     = $PROJECT_DIR"
    echo "PROJECT_NAME    = $PROJECT_NAME"
    echo "PROJECT_VERSION = $PROJECT_VERSION"

    # https://www.gnu.org/software/autoconf/manual/autoconf-2.69/html_node/Versioning.html
    AUTOCONF_VERSION_MREQUIRED=$(grep 'AC_PREREQ\s*(\[.*\])\s*$' configure.ac | sed 's/AC_PREREQ\s*(\[\(.*\)\])/\1/')

    step "load $RC_FILE"
    if file_exists "$RC_FILE" ; then
        if . "$RC_FILE" ; then
            success "$RC_FILE loaded successfully."
        else
            die "$RC_FILE load failed."
        fi
    else
        warn "$RC_FILE not exist. skipped."
    fi

    regist_dependency required command autoconf ge "$AUTOCONF_VERSION_MREQUIRED"
    regist_dependency required command automake
    regist_dependency required command m4
    regist_dependency required command perl
    regist_dependency required command make:gmake:bmake

    __is_libtool_used &&
    regist_dependency required command libtoolize

    __handle_required_dependencies || return 1
    __printf_required_dependencies
    __printf_optional_dependencies

    gen_config_pre  || return 1
    gen_config      || return 1
    gen_config_post || return 1

    echo
    success "Done."
}

main $@
