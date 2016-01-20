#!/bin/bash
. testsrc

ME=`whoami`

if [ -z "$POOL_DEFAULT" ] ; then
  export POOL_DEFAULT='10.100.0.0/16:24'
else
  export POOL_DEFAULT="$POOL_DEFAULT"
fi

if [ -z "$FUEL_DEVOPS" ] ; then
  export FUEL_DEVOPS='FUEL_DEVOPS'
else
  export FUEL_DEVOPS="$FUEL_DEVOPS"
fi

if [ -z "$FUEL_QA" ] ; then
  export FUEL_QA='/opt/fuel-qa'
else
  export FUEL_QA="$FUEL_QA"
fi

sh "$FUEL_QA/utils/jenkins/system_tests.sh" -t test -w $(pwd) -j "$ME-venv" -i "$ISO_PATH" -V $FUEL_DEVOPS -o --group=$MY_GROUP $@

