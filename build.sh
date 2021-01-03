#!/usr/bin/bash

LOGFILE="build.log"
FILES="."
MESSAGE="$0 at $(date)"

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


echo "$0 started at $(date)\n\n" | tee $LOGFILE
mkdocs build --site-dir build --verbose --strict &>> $LOGFILE

if [[ $NOCOMMIT && $NODEPLOY ]]; then
	echo "Local build complete and -d was specified, exiting." | tee -a $LOGFILE
	exit 0;
fi

if [[ $? -eq 0 ]]; then
	echo "\n\nTest build succeeded, committing to main \n\n" | tee -a $LOGFILE

	git add $FILES &>> $LOGFILE
	git commit -m "$MESSAGE" &>> $LOGFILE
	git push origin main &>> $LOGFILE

	if [[ $NODEPLOY ]]; then
		echo "\n\n Pushed to main and -b was specified, exiting." | tee -a $LOGFILE
		exit 0;
	fi

	echo "\n\nRunning mkdocs gh-deploy...\n\n" | tee -a $LOGFILE
	mkdocs gh-deploy --strict &>> $LOGFILE

	if [[ $? -eq 0 ]]; then
		echo "\n\nmkdocs gh-deploy succeeded, exiting.\n\n" | tee -a $LOGFILE
		exit 0
	else
		echo "\n\nmkdocs gh-deploy exited with nonzero status ${?}, see logfile ${LOGFILE}" | tee -a $LOGFILE
		exit 1
	fi

else

	echo "\n\nTest build exited with nonzero exit status, see logfile ${LOGFILE}" | tee -a $LOGFILE
	exit 1
fi
