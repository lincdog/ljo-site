#!/usr/bin/bash

ENV_NAME="mkdocs"

while getopts ":he:" OPTION; do
	case $OPTION in
	e)
		ENV_NAME=$OPTARG
		;;
	h | *)
		usage
		;;
	esac
done

CONDA=$(which conda)

if [[ $? -ne 0 ]]; then
	echo "Conda not found, exiting..." > 2
	exit 1
fi

conda activate $ENV_NAME

if [[ $? -ne 0 ]]; then
	echo "Conda environment ${ENV_NAME} not found, creating..." > 2
	conda create -n $ENV_NAME
	conda activate $ENV_NAME
fi

pip install -r requirements.txt &>> setup.log
