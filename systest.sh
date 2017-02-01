#!/bin/bash
#
set -u -e
#
# Defaults
readlinkf(){ readlink -f "$1"; }
SCRIPTPATH="$(cd "$(dirname "$(readlinkf "${BASH_SOURCE[@]}")")" ; pwd)"
INSTALL_VARIABLES="(fuel-11|fuel-10|fuel-9.0|fuel-9.1|fuel-9.2|fuel-ccp-k8s)"
USR=$(whoami)


show_help() {
  if [ -t 1 ]; then
    echo -e "\e[34m### System Tests Script ###\e[0m                       "
    echo -e "                                                             "
    echo -e " \e[1m -i \e[0m (str)    - Specify that you want to install. "
    echo -e "                 Possible options:                           "
    echo -e "                \e[33m ${INSTALL_VARIABLES} \e[0m            "
    echo -e " \e[1m -h \e[0m          - Show this help page.              "
    echo -e "                                                             "
    echo -e "\e[34m### System Tests Script ###\e[0m                       "
  else
      echo "### System Tests Script ###                       "
      echo "                                                  "
      echo "  -i (str)    - Specify that you want to install. "
      echo "                Possible options:                 "
      echo "                ${INSTALL_VARIABLES}              "
      echo "  -h          - Show this help page.              "
      echo "                                                  "
      echo "### System Tests Script ###                       "
  fi
}


getopts_variables() {
  while getopts ":i:h" opt; do
    case ${opt} in
      i)
        TO_INSTALL="${OPTARG}" 
        ;;
      h)
        show_help
        exit 0
        ;;
      \?)
        if [ -t 1 ]; then
          echo -e "                                         "
          echo -e " \e[31m Invalid option: -${OPTARG} \e[0m "
          echo -e "                                         "
          show_help
          exit 1
        else
            echo "                            "
            echo " Invalid option: -${OPTARG} "
            echo "                            "
            show_help
            exit 1
        fi
        ;;
      :)
        if [ -t 1 ]; then
          echo -e "                                                      "
          echo -e " \e[31m Option -${OPTARG} requires an argument. \e[0m "
          echo -e "                                                      "
          show_help
          exit 1
        else
            echo "                                         "
            echo " Option -${OPTARG} requires an argument. "
            echo "                                         "
            show_help
            exit 1
        fi
        ;;
    esac
  done
}


check_variables() {
  if [[ ! ${TO_INSTALL:-} ]]; then
    if [ -t 1 ]; then
      echo -e "                                            "
      echo -e " \e[31m Error! TO_INSTALL is not set! \e[0m "
      echo -e "                                            "
      show_help
      exit 1
    else
        echo "                               "
        echo " Error! TO_INSTALL is not set! "
        echo "                               "
        show_help
        exit 1
    fi
  else
      if [[ "${TO_INSTALL}" =~ ^${INSTALL_VARIABLES}$ ]]; then
        if [ -t 1 ]; then
          echo -e "                                                "
          echo -e " \e[32m You want to install ${TO_INSTALL} \e[0m "
          echo -e "                                                "
        else
          echo "                                   "
          echo " You want to install ${TO_INSTALL} "
          echo "                                   " 
        fi
      else
          if [ -t 1 ]; then
            echo -e "                                                       "
            echo -e " \e[31m Error! Specify that you want to install. \e[0m "
            echo -e "                                                       "
            show_help
            exit 1
          else
              echo "                                          "
              echo " Error! Specify that you want to install. "
              echo "                                          "
              show_help
              exit 1
          fi
      fi
  fi
  if [[ ! ${POOL_DEFAULT:-} ]]; then
    if [ -t 1 ]; then
      echo -e "                                                                                          "
      echo -e " \e[31m Error! POOL_DEFAULT is not set! Something's wrong with your profile or lab. \e[0m "
      echo -e "                                                                                          "
      exit 1
    else
        echo "                                                                             "
        echo " Error! POOL_DEFAULT is not set! Something's wrong with your profile or lab. "
        echo "                                                                             "
        exit 1
    fi
  fi
}


global_and_specific_variables() {
  source "${SCRIPTPATH}/testsrc"
}


run_test() {
  case ${1} in
    fuel-ccp-k8s)
      bash -x "${CCP_INSTALLER_DIR}/utils/jenkins/run_k8s_deploy_test.sh"
      ;;
    *)
      if [ -t 1 ]; then
        echo -e "                                                           "
        echo -e " \e[33m ATTENTION! Logs will be saved in ${LOGS_DIR} \e[0m "
        echo -e "                                                           "
        bash -x "${FUEL_QA}/utils/jenkins/system_tests.sh" -w "${FUEL_QA}" -j "${USR}-venv" -i "${ISO_PATH}" -V "${VENV_PATH}" -l "${LOGS_DIR}" -o --group="${MY_GROUP}"
      else
          echo "                                              "
          echo " ATTENTION! Logs will be saved in ${LOGS_DIR} "
          echo "                                              "
          bash -x "${FUEL_QA}/utils/jenkins/system_tests.sh" -w "${FUEL_QA}" -j "${USR}-venv" -i "${ISO_PATH}" -V "${VENV_PATH}" -l "${LOGS_DIR}" -o --group="${MY_GROUP}"
      fi
      ;;
  esac
}


### MAIN ###

# first we want to get variable from command line options
getopts_variables "${@}"

# check do we have all critical variables set
check_variables

# then we define global and specific variables
global_and_specific_variables

# run the test
run_test "${TO_INSTALL}"
