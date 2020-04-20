[ -n "$BASH_VERSION" ] || return 0

export IMPALA_HOME=/apache-impala-VERSION
source $IMPALA_HOME/bin/impala-config.sh >/dev/null
unset LD_LIBRARY_PATH
