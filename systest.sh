#!/bin/bash

pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

source $SCRIPTPATH/testsrc

ME=`whoami`

if [ -z "$POOL_DEFAULT" ] ; then
  export POOL_DEFAULT='10.100.0.0/16:24'
else
  export POOL_DEFAULT="$POOL_DEFAULT"
fi

if [ -z "$FUEL_DEVOPS_VENV" ] ; then
  export FUEL_DEVOPS_VENV='/opt/fuel-devops-venv'
else
  export FUEL_DEVOPS_VENV="$FUEL_DEVOPS_VENV"
fi

if [ -z "$FUEL_QA" ] ; then
  export FUEL_QA='/opt/fuel-qa'
else
  export FUEL_QA="$FUEL_QA"
fi

if [ -z "$LOGS_DIR" ] ; then
  export LOGS_DIR="/home/$(whoami)/systest-logs"
else
  export LOGS_DIR="$LOGS_DIR"
fi

echo
echo "ATTENTION! Logs will be saved in $LOGS_DIR"
echo
sh "$FUEL_QA/utils/jenkins/system_tests.sh" -t test -w $FUEL_QA -j "$ME-venv" -i "$ISO_PATH" -V $FUEL_DEVOPS_VENV -o --group=$MY_GROUP $@

