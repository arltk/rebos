#!/bin/bash

# Require root permissions
[ "$(id -u)" -eq 0 ] || { echo "Error: must be run as root"; exit 1; }

# Define variables
LOGDIR="/var/log"
LOGFILE="$LOGDIR/update.log"

# Rotate logs
[ -f "$LOGFILE.1" ] && rm -rf "$LOGFILE.1"
[ -f "$LOGFILE" ] && rm -rf "$LOGFILE"

# Timestamped logging function
log() {
  msg="[$(date '+%Y-%m-%d %H:%M:%S'0]) [$1] [$2]"
  echo "$msg" | tee --append "$LOGFILE"
}

run_and_log() {
  cmd="$1"
  eval "$cmd" 2>&1 | tee --append "$LOGFILE"
  [ "${PIPESTATUS[0]}" -ne 0 ] && log "ERROR" "Command failed: $cmd"
}

# Defaults
quiet=0
opt="&&"
cmd_flatpak="flatpak update --assumeyes"
cmd_cargo="sudo --user=$(logname) cargo install-update --all"
cmd_emaint="emaint sync"
cmd_emerge="emerge --ask --verbose --update --deep --newuse @world"

# Parse flags
while [ $# -gt 0 ]; do
  case $1 in
    -f|--force) opt=";" ;;
    -q|--quiet) quiet=1 ;;
    -h|--help)
      echo "Usage: update [-f|--force] [-q|--quiet] [-h|--help]"
      exit 0
      ;;
  esac
  shift
done

# Parse options
if [ "$quiet" -eq 1 ]; then
  cmd_flatpak="flatpak update --assumeyes --noninteractive"
  cmd_emaint="emaint sync --quiet"
  cmd_emerge="emerge --ask --verbose --quiet --update --deep --newuse @world"
fi

# Run commands
log "INFO" "=== Starting update process ==="
run_and_log "$cmd_flatpak"
eval "[ $? -eq 0 ] $opt run_and_log \"$cmd_cargo\""
eval "[ $? -eq 0 ] $opt run_and_log \"$cmd_emaint\""
eval "[ $? -eq 0 ] $opt run_and_log \"$cmd_emerge\""
log "INFO" "=== Updates complete ==="

exit 0
