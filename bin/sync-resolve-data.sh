#!/usr/bin/env bash

set -euo pipefail

SCRIPT_NAME=$(basename "${0}")

REMOTE_HOST="beast"
REMOTE_DIRS=(
    "/media/hunmonk/storage/video/Resolve Project Backups"
    "/media/hunmonk/storage/resolve/Resolve Projects"
)
LOCAL_DIR="${HOME}/beast/resolve"
ENSURE_TASK_SCRIPT="${HOME}/bin/ensure-task.sh"

usage() {
    echo "Usage: ${0} [-h]"
    echo "Sync Resolve data from beast to local machine."
    echo ""
    echo "Options:"
    echo "  -h    Show this help message and exit"
}

test_connection() {
    if ! ssh -q -o BatchMode=yes -o ConnectTimeout=5 "${REMOTE_HOST}" exit; then
        echo "Error: Cannot connect to ${REMOTE_HOST}" >&2
        exit 1
    fi
}

sync_data() {
    local remote_dir="${1}"

    rsync -avz --progress --delete \
        "${REMOTE_HOST}:${remote_dir}" "${LOCAL_DIR}/"
}

main() {
    while getopts ":h" opt; do
        case ${opt} in
            h )
                usage
                exit 0
                ;;
            \? )
                echo "Invalid option: -${OPTARG}" >&2
                usage
                exit 1
                ;;
        esac
    done

    test_connection

    mkdir -p "${LOCAL_DIR}"

    for remote_dir in "${REMOTE_DIRS[@]}"; do
        sync_data "${remote_dir}"
        if [ $? -eq 0 ]; then
            logger "${SCRIPT_NAME}: Success: Synced data from ${remote_dir}"
        else
            local message="${SCRIPT_NAME}: Error: Failed to sync data from ${remote_dir}"
            logger "${message}"
            ${ENSURE_TASK_SCRIPT} resolve "${message}"
        fi
    done

    echo "Sync completed successfully."
}

main "$@"
