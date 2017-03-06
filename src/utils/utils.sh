is_process_running()
{
    PIDFILE=$1
    # Returns 1 if 'omsagent' is running, 0 otherwise
    [ -f $PIDFILE ] || return 0
    ps -p `cat $PIDFILE` | grep -q omsagent
    STATUS=$?

    # Kill PID file if we're not running any longer
    if [ $STATUS -ne 0 ]; then
        rm -f $PIDFILE
        return 0
    else
        return 1
    fi
}


wait_until_process_stops()
{
    # Required parameter: Number of seconds to wait for agent to stop
    if [ -z "$1" -o -z "$2" -o "$2" -le 0 ]; then
        echo "Function \"wait_until_process_stops\" called with invalid parameter"
        exit 1
    fi

    PIDFILE=$1
    TIME=$2

    COUNTER=$(( $TIME * 2 )) # Since we sleep 0.5 seconds, compute number of seconds
    while [ $COUNTER -gt 0 ]; do
        is_process_running $PIDFILE && return $?
        COUNTER=$(( $COUNTER - 1 ))
        sleep 0.5
    done

    # One final try for accurate return status (just return status from the call)
    is_process_running $PIDFILE
}

pid_guard() {
  echo "------------ STARTING `basename $0` at `date` --------------" | tee /dev/stderr
  pidfile=$1
  name=$2

  if [ -f "$pidfile" ]; then
    pid=$(head -1 "$pidfile")

    if [ -n "$pid" ] && [ -e /proc/$pid ]; then
      echo "$name is already running, please stop it first"
      exit 1
    fi

    echo "Removing stale pidfile..."
    rm $pidfile
  fi
}

