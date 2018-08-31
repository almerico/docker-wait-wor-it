#!/usr/bin/env bash

echoerr() { if [[ $QUIET -ne 1 ]]; then echo "$@" 1>&2; fi }

parse_arguments() {
  local index=0
  echoerr "wait script parameters:"$@
  echoerr "number of params" $#
  while [[ $# -gt 0 ]]
  do
      case "$1" in
          *:* )
          hostport=(${1//:/ })
          HOST[$index]=${hostport[0]}
          echoerr "host =" ${hostport[0]}
          PORT[$index]=${hostport[1]}
          echoerr "port ="${hostport[1]}
          shift 1
          ;;
          -q | --quiet)
          QUIET=1
          shift 1
          ;;
          -t)
          TIMEOUT="$2"
          if [[ $TIMEOUT == "" ]]; then break; fi
          shift 2
          ;;
          --timeout=*)
          TIMEOUT="${1#*=}"
          shift 1
          ;;
          --)
          shift
          CLI="$@"
          break
          ;;
          --help)
          usage
          ;;
          *)
          echoerr "Unknown argument: $1"
          usage
          ;;
      esac
      let index+=1
  done
}


usage() {
    cat << USAGE >&2
Usage:
    $cmdname host:port [-s] [-t timeout] [-- command args]
    -s | --strict               Only execute subcommand if the test succeeds
    -q | --quiet                Don't output any status messages
    -t TIMEOUT | --timeout=TIMEOUT
                                Timeout in seconds, zero for no timeout
    -- COMMAND ARGS             Execute command with args after the test finishes
USAGE
#    exit 1
}
iterate_hosts() {
  local result=0
  local index=0
  local wait_function=$1
  local timer=0;
  echoerr "iterate_hosts called number of hosts" ${#HOST[@]}

  while [[ $index -lt ${#HOST[@]} ]]; do

    echoerr checking ${HOST[$index]} ${PORT[$index]}
    while  ! nc -w 1 -z ${HOST[$index]} ${PORT[$index]};  do
           if [[ $QUIET -eq "" ]]; then
                 echoerr waiting for  ${HOST[$index]} ${PORT[$index]};
           fi
           sleep 1
           let timer+=1
           if [[ $TIMEOUT -gt 0 ]]; then
                if [[ $TIMEOUT -lt $timer ]]; then
                    echoerr "TImeout $TIMEOUT exceeded $timer"
                    exit -2;
                fi
            fi
    done
    let index+=1
  done
    echoerr "iterate_hosts ended"
}

parse_arguments "$@"
iterate_hosts

if [[ $CLI != "" ]]; then
   exec $CLI
fi