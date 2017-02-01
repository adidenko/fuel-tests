#!/bin/bash
#
# Defaults
pushd "$(dirname "$0")" > /dev/null
SCRIPTPATH=$(pwd)
popd > /dev/null
INSTALL_VARIABLES="(fuel-11|fuel-10|fuel-9.0|fuel-9.1|fuel-9.2|fuel-ccp-k8s)"
USR=$(whoami)


ShowHelp() {
  echo -e "\e[34m### System Tests Script ###\e[0m                       "
  echo -e "                                                             "
  echo -e " \e[1m -i \e[0m (str)    - Specify that you want to install. "
  echo -e "                 Possible options:                           "
  echo -e "                \e[33m ${INSTALL_VARIABLES} \e[0m            "
  echo -e " \e[1m -h \e[0m          - Show this help page.              "
  echo -e "                                                             "
  echo -e "\e[34m### System Tests Script ###\e[0m                       " 
}


GetoptsVariables() {
  while getopts ":i:h" opt; do
    case ${opt} in
      i)
        WHAT_INSTALL="${OPTARG}" 
        ;;
      h)
        ShowHelp
        exit 0
        ;;
      \?)
        echo -e "                                         "
        echo -e " \e[31m Invalid option: -${OPTARG} \e[0m "
        echo -e "                                         "
        ShowHelp
        exit 1
        ;;
      :)
        echo -e "                                                      "
        echo -e " \e[31m Option -${OPTARG} requires an argument. \e[0m "
        echo -e "                                                      "
        ShowHelp
        exit 1
        ;;
    esac
  done
}


CheckVariables() {
  if [ -z "${WHAT_INSTALL}" ]; then
    echo -e "                                              "
    echo -e " \e[31m Error! WHAT_INSTALL is not set! \e[0m "
    echo -e "                                              "
    ShowHelp
    exit 1
  else
      if [[ "${WHAT_INSTALL}" =~ ^${INSTALL_VARIABLES}$ ]]; then
        echo -e "                                                  "
        echo -e " \e[32m You want to install ${WHAT_INSTALL} \e[0m "
        echo -e "                                                  "
      else
        echo -e "                                                       "
        echo -e " \e[31m Error! Specify that you want to install. \e[0m "
        echo -e "                                                       "
        ShowHelp
        exit 1
      fi
  fi
  if [ -z "${POOL_DEFAULT}" ]; then
    echo -e "                                                                                          "
    echo -e " \e[31m Error! POOL_DEFAULT is not set! Something's wrong with your profile or lab. \e[0m "
    echo -e "                                                                                          "
    exit 1
  fi
}


GlobalAndSpecificVariables() {
  source "${SCRIPTPATH}/testsrc"
}


RunTest() {
  case ${1} in
    fuel-ccp-k8s)
      echo bash -x "${CCP_INSTALLER_DIR}/utils/jenkins/run_k8s_deploy_test.sh"
      ;;
    *)
      echo -e "                                                           "
      echo -e " \e[33m ATTENTION! Logs will be saved in ${LOGS_DIR} \e[0m "
      echo -e "                                                           "
      echo bash -x "${FUEL_QA}/utils/jenkins/system_tests.sh" -w "${FUEL_QA}" -j "${USR}-venv" -i "${ISO_PATH}" -V "${VENV_PATH}" -l "${LOGS_DIR}" -o --group="${MY_GROUP}"
      ;;
  esac
}


### MAIN ###

# first we want to get variable from command line options
GetoptsVariables "${@}"

# check do we have all critical variables set
CheckVariables

# then we define global and specific variables
GlobalAndSpecificVariables

# run the test
RunTest "${WHAT_INSTALL}"
