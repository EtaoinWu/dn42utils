#!/bin/sh

#############################################
# Babeld docker container entrypoint script #
#############################################

# exit on error
set -e

# function to handle shutdown signals
shutdown() {
  echo "Shutting down Babeld..."
  kill -TERM "$BABELD_PID"
  wait "$BABELD_PID"
  echo "Babeld stopped."
  exit 0
}
trap shutdown TERM INT

COMMAND_LINE_OPTIONS=""
BABELD_LOCATION="/usr/local/bin/babeld"

# helper functions to handle options
add_binary_option() {
  VAR_NAME=$1
  OPTION_FLAG=$2
  eval "VAR_VALUE=\$$VAR_NAME"

  if [ -n "$VAR_VALUE" ] && [ "$VAR_VALUE" != "false" ] && [ "$VAR_VALUE" != "0" ]; then
    COMMAND_LINE_OPTIONS="$COMMAND_LINE_OPTIONS $OPTION_FLAG"
  fi
}

add_string_option() {
  VAR_NAME=$1
  OPTION_FLAG=$2
  eval "VAR_VALUE=\$$VAR_NAME"

  if [ -n "$VAR_VALUE" ]; then
    COMMAND_LINE_OPTIONS="$COMMAND_LINE_OPTIONS $OPTION_FLAG $VAR_VALUE"
  fi
}

add_list_option() {
  VAR_NAME=$1
  OPTION_FLAG=$2
  eval "VAR_VALUE=\$$VAR_NAME"

  if [ -n "$VAR_VALUE" ]; then
    if [ "$(echo "$VAR_VALUE" | cut -c1)" = "[" ] && [ "$(echo "$VAR_VALUE" | rev | cut -c1)" = "]" ]; then
      # JSON array
      for ITEM in $(echo "$VAR_VALUE" | jq -r '.[]'); do
        COMMAND_LINE_OPTIONS="$COMMAND_LINE_OPTIONS $OPTION_FLAG $ITEM"
      done
    else
      # single item
      COMMAND_LINE_OPTIONS="$COMMAND_LINE_OPTIONS $OPTION_FLAG $VAR_VALUE"
    fi
  fi
}

BABEL_CONFIG_FILE_DEFAULT="/data/babeld.conf"

# if BABELD_CONFIG_FILE is not set and the default config file exists, use it
if [ -z "$BABELD_CONFIG_FILE" ] && [ -f "$BABEL_CONFIG_FILE_DEFAULT" ]; then
  BABELD_CONFIG_FILE="$BABEL_CONFIG_FILE_DEFAULT"
fi

add_string_option "BABELD_CONFIG_FILE" "-c"

# Add options based on environment variables
add_string_option "BABELD_MULTICAST_ADDRESS" "-m"
add_string_option "BABELD_PORT" "-p"
add_string_option "BABELD_STATIC_FILE" "-S"
add_string_option "BABELD_HELLO_INTERVAL_WIRELESS" "-h"
add_string_option "BABELD_HELLO_INTERVAL_WIRED" "-H"
add_string_option "BABELD_HALF_TIME" "-M"
add_string_option "BABELD_KERNEL_ROUTE_PRIORITY" "-k"
add_string_option "BABELD_EXTERNAL_PRIORITY_THRESHOLD" "-A"
add_string_option "BABELD_DEBUG_LEVEL" "-d"
add_string_option "BABELD_LOCAL_CONFIG_SERVER_RO" "-g"
add_string_option "BABELD_LOCAL_CONFIG_SERVER_RW" "-G"
add_string_option "BABELD_INSERT_TO_TABLE" "-t"
add_string_option "BABELD_LOGFILE" "-L"
add_string_option "BABELD_PID_FILE" "-I"

add_binary_option "BABELD_IFF_RUNNING" "-l"
add_binary_option "BABELD_ASSUME_ALL_WIRELESS" "-w"
add_binary_option "BABELD_DISABLE_SPLIT_HORIZON_PROCESSING_WIRED" "-s"
add_binary_option "BABELD_RANDOMIZE_ROUTER_ID" "-r"
add_binary_option "BABELD_NO_FLUSH_UNFEASIBLE_ROUTE" "-u"
add_binary_option "BABELD_DEMONISE" "-D"

add_list_option "BABELD_EXPORT_FROM_TABLES" "-T"
add_list_option "BABELD_CONFIG_VERBATIM" "-C"

COMMAND_LINE_OPTIONS="$COMMAND_LINE_OPTIONS $BABELD_EXTRA_OPTIONS"

# Add interface option if BABELD_INTERFACES is set
if [ -n "$BABELD_INTERFACES" ]; then
  COMMAND_LINE_OPTIONS="$COMMAND_LINE_OPTIONS -- $BABELD_INTERFACES"
fi

echo "Starting Babeld with command line options: $COMMAND_LINE_OPTIONS"
$BABELD_LOCATION $COMMAND_LINE_OPTIONS &
BABELD_PID=$!

wait $BABELD_PID
