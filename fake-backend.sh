#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(readlink -f "${0%/*}")
readonly SCRIPT_DIR
readonly HOST_DEFAULT="127.0.0.1"
readonly PORT_DEFAULT="8080"
HTTP_RESPONSE_FILE_DEFAULT="${SCRIPT_DIR}/http_response_200.txt"
readonly HTTP_RESPONSE_FILE_DEFAULT

serve() {
    local host="$1"
    local port="$2"
    local http_response="$3"
    while true; do 
        echo "$http_response" | nc -N -l "$host" "$port"
    done
}

usage() {
cat << EOF
Usage: $(basename "$0") [OPTIONS]

Run a fake server bound to specified host and port and returning a file defined HTTP response

Options:
    -H, --host          Host (default 127.0.0.1)
    -p, --port          Port (default 8080)
    -f, --http-file     HTTP response file (default $SCRIPT_DIR/http_reponse_200.txt)

Example:
    $(basename "$0") -H 127.0.0.1 -p 8081 -f /home/alice/http_response_custom.txt
EOF
}

main() {
    local host="$HOST_DEFAULT"
    local port="$PORT_DEFAULT"
    local http_response_file="$HTTP_RESPONSE_FILE_DEFAULT"
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
            -H|--host)
            host="$2"
            shift && shift;;
            -p|--port)
            port="$2"
            shift && shift;;
            -f|--http-file)
            http_response_file="$2"
            shift && shift;;
            *)
            usage
            exit 1
        esac
    done

    printf "Serving HTTP with netcat [host=%s] [port=%s] [http-file=%s]\n" "$host" "$port" "$http_response_file"
    printf "Avaiblable at http://%s:%s\n" "$host" "$port" 
    
    serve "$host" "$port" "$(<"$http_response_file")"
}

main "$@"
