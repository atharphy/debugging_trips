#!/bin/bash

BASE_DIR="/nfspixelraid/nfspixelraid"

usage() {
    echo "Usage:"
    echo "  $0 -log0 [-last | -last N | <folder_name>]"
    echo "  $0 -log1 -bpix [-last | -last N | <folder_name>]"
    echo "  $0 -log1 -fpix [-last | -last N | <folder_name>]"
    exit 1
}

if [[ "$1" == "-log0" ]]; then
    BASE_PATH="${BASE_DIR}/log0"
    shift
    if [[ "$1" == "-last" ]]; then
        if [[ "$2" =~ ^[0-9]+$ ]]; then
            COUNT=$2
        else
            COUNT=1
        fi
        LOG_DIRS=$(ls -td ${BASE_PATH}/*/ 2>/dev/null | head -n "$COUNT")
    elif [[ -n "$1" ]]; then
        LOG_DIRS="${BASE_PATH}/$1"
    else
        usage
    fi
elif [[ "$1" == "-log1" ]]; then
    shift
    if [[ "$1" == "-bpix" ]]; then
        BASE_PATH="${BASE_DIR}/log1/BPix"
        shift
    elif [[ "$1" == "-fpix" ]]; then
        BASE_PATH="${BASE_DIR}/log1/FPix"
        shift
    else
        usage
    fi

    if [[ "$1" == "-last" ]]; then
        if [[ "$2" =~ ^[0-9]+$ ]]; then
            COUNT=$2
        else
            COUNT=1
        fi
        LOG_DIRS=$(ls -td ${BASE_PATH}/*/ 2>/dev/null | head -n "$COUNT")
    elif [[ -n "$1" ]]; then
        LOG_DIRS="${BASE_PATH}/$1"
    else
        usage
    fi
else
    usage
fi

for LOG_DIR in $LOG_DIRS; do
    LOG_FILE=$(ls -t "${LOG_DIR}"/PixelDCS*.log 2>/dev/null | head -1)
    if [[ ! -f "$LOG_FILE" ]]; then
        echo "No PixelDCS log file found in $LOG_DIR"
        continue
    fi

    echo
    echo "=== Folder: $(echo "$LOG_DIR" | sed "s|$BASE_DIR/||") ==="
    echo "Using log file: $LOG_FILE"
    echo

    awk -v log_date="$(basename "$LOG_DIR" | sed -E 's/Log_([0-9]{2}[A-Za-z]{3}[0-9]{4}).*/\1/')" '
    BEGIN {
        fmt="%-30s %-12s %-10s %-40s %-7s %-7s %-14s %-8s %-10s\n"
        printf fmt, "Module", "Date", "Time", "Number of FSM nodes of type",
                     "HV_ON", "LV_ON", "LV_ON_REDUCED", "LV_OFF", "UNDEFINED"
        print "-----------------------------------------------------------------------------------------------------------------------------------------------------------"
    }
    /ERROR<\/smi:notify>/ {
        match($0, /object="[^"]+"/, obj);
        split(obj[0], parts, ":");
        module = parts[length(parts)];
        gsub(/"/, "", module);

        getline;
        time = "N/A";
        if ($0 ~ /notify]/) {
            n = split($0, f, " ");
            time = f[3];
        }

        while ((getline line) > 0) {
            if (line ~ /Number of FSM nodes of type/) {
                match(line, /type +([A-Za-z0-9_]+) +\(([A-Za-z0-9_]+)\)/, t);
                type = t[1] " (" t[2] ")";
                getline; match($0, /"HV_ON" *= *([0-9]+)/, a); hv=a[1];
                getline; match($0, /"LV_ON" *= *([0-9]+)/, b); lv=b[1];
                getline; match($0, /"LV_ON_REDUCED" *= *([0-9]+)/, c); lvr=c[1];
                getline; match($0, /"LV_OFF" *= *([0-9]+)/, d); lvo=d[1];
                getline; match($0, /"UNDEFINED" *= *([0-9]+)/, e); un=e[1];
                printf fmt, module, log_date, time, type,
                           (hv ? hv : 0), (lv ? lv : 0),
                           (lvr ? lvr : 0), (lvo ? lvo : 0), (un ? un : 0)
                break;
            }
        }
    }' "$LOG_FILE"
done
