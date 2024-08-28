#!/usr/bin/env bash

set -euo pipefail
# IFS=$'\n\t'

readonly SCRIPT_NAME=$(basename "${0}")
readonly AUTOTASK_TAG="autotask"

# Function to log messages
log_message() {
    local level="${1}"
    local message="${2}"
    logger -t "${SCRIPT_NAME}" -p "user.${level}" "${message}"
}

# Function to ensure a task exists in TaskWarrior
ensure_task() {
    local custom_tag="${1}"
    local description="${2}"

    # Add '+' prefix to tag if not present
    [[ ${custom_tag} != +* ]] && custom_tag="+${custom_tag}"

    # Check if the task already exists
    if task rc.hooks=0 rc.verbose=0 rc.confirmation=0 project:INBOX +PENDING "+${AUTOTASK_TAG}" "${custom_tag}" count 2>/dev/null | grep -q '1'; then
        log_message "info" "Task already exists: ${custom_tag} ${description}"
    else
        # Add the task
        if task rc.hooks=0 rc.verbose=0 rc.confirmation=0 add project:INBOX "+${AUTOTASK_TAG}" "${custom_tag}" "${description}"; then
            log_message "info" "Added new task: ${custom_tag} ${description}"
        else
            log_message "err" "Failed to add task: ${custom_tag} ${description}"
            return 1
        fi
    fi
}

# Function to display usage instructions
usage() {
    cat << EOF
Usage: ${SCRIPT_NAME} <custom_tag> <task_description>

Ensure a task exists in TaskWarrior with the given tag.

Arguments:
  <custom_tag>       A unique tag for the task
  <task_description> Description of the task to be added

The script will:
2. Check if a task with the given tag already exists
3. If it doesn't exist, add the task to the INBOX project with +${AUTOTASK_TAG} tag
4. Log the result of the operation to syslog

Example:
  ${SCRIPT_NAME} daily_review "Review tasks and calendar for the day"
EOF
}

# Main execution
main() {
    if [[ "${#}" -ne 2 ]]; then
        usage >&2
        exit 1
    fi

    ensure_task "${1}" "${2}"
}

main "${@}"
