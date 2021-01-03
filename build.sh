#!/usr/bin/bash

LOGFILE="build.log"
FILES="."
MESSAGE="$0 at $(date)"
ENV_PATH="mkdocs_env"

usage() { 
	echo " 
Usage: $0 [-d] [-b] [-m <message>] [-f <files>] [ -l <logfile> ]

-d	dry-run, only build local copy, do not commit or deploy site.
-b	build only, build and commit to main but do not deploy site.
-m MESSAGE	supply a commit message for the main branch
-f FILES	supply files to be committed to main; default .
-l LOGFILE	specify a logfile name; default build.log
"

	exit 0;
}

cleanup_exit() {
	if [[ $VENV -eq 1 ]]; then
		deactivate
	fi

	exit $1
}


while getopts ":dbm:f:l:" OPTION; do
	case $OPTION in
	d)
		NOCOMMIT=1
		NODEPLOY=1
		;;
	b)
		NODEPLOY=1
		;;
	m)
		MESSAGE=$OPTARG
		;;
	f)
		FILES=$OPTARG
		;;
	l)
		LOGFILE=$OPTARG
		;;
	h)
		usage
		;;
	*)
		usage
		;;
	esac
done


echo "$0 started at $(date)" | tee $LOGFILE

if [[ -e $ENV_PATH ]]; then
	source $ENV_PATH/bin/activate
	VENV=1
else
	VENV=0
fi


mkdocs build --site-dir build --verbose --strict &>> $LOGFILE
TEST_STATUS=$?

if [[ $NOCOMMIT && $NODEPLOY ]]; then
	if [[ $TEST_STATUS -eq 0 ]]; then
		echo "Local build complete and -d was specified, exiting." | tee -a $LOGFILE
		cleanup_exit 0;
	else
		echo "Local build exited with nonzero exit status, see logfile $LOGFILE" | tee -a $LOGFILE
		cleanup_exit 1;
	fi
fi

if [[ $TEST_STATUS -eq 0 ]]; then
	echo "Test build succeeded, committing to main" | tee -a $LOGFILE

	git add $FILES &>> $LOGFILE
	git commit -m "$MESSAGE" &>> $LOGFILE
	git push origin main &>> $LOGFILE

	if [[ $NODEPLOY ]]; then
		echo "Pushed to main and -b was specified, exiting." | tee -a $LOGFILE
		cleanup_exit 0;
	fi

	echo "Running mkdocs gh-deploy..." | tee -a $LOGFILE
	mkdocs gh-deploy --strict &>> $LOGFILE

	if [[ $? -eq 0 ]]; then
		echo "mkdocs gh-deploy succeeded, exiting." | tee -a $LOGFILE
		cleanup_exit 0
	else
		echo "mkdocs gh-deploy exited with nonzero status ${?}, see logfile ${LOGFILE}" | tee -a $LOGFILE
		cleanup_exit 1
	fi

else

	echo "Test build exited with nonzero exit status, see logfile ${LOGFILE}" | tee -a $LOGFILE
	cleanup_exit 1
fi

