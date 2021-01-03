#!/usr/bin/bash

ENV_PATH="mkdocs_env"

while getopts ":he:" OPTION; do
	case $OPTION in
	e)
		ENV_PATH=$OPTARG
		;;
	h | *)
		usage
		;;
	esac
done


python -m venv $ENV_PATH
source $ENV_PATH/bin/activate
pip install -r requirements.txt &> setup.log
