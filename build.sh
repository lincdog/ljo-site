#!/usr/bin/bash

LOGFILE="build.log"

echo "build.sh started at $(date)" | tee $LOGFILE
mkdocs build --site-dir build --verbose --strict &>> $LOGFILE

if [[ $? -eq 0 ]]; then
	echo "Test build succeeded, committing to main" | tee -a $LOGFILE

	git add . &>> $LOGFILE
	git commit -m "build at $(date)" &>> $LOGFILE
	git push origin main &>> $LOGFILE

	echo "Running mkdocs gh-deploy..." | tee -a $LOGFILE
	mkdocs gh-deploy --verbose --strict &>> $LOGFILE

	if [[ $? -eq 0 ]]; then
		echo "mkdocs gh-deploy succeeded, exiting." | tee -a $LOGFILE
	else
		echo "mkdocs gh-deploy exited with nonzero status ${?}, see logfile ${LOGFILE}" | tee -a $LOGFILE
		exit 1
	fi

else

	echo "Test build exited with nonzero exit status, see logfile ${LOGFILE}" | tee -a $LOGFILE
	exit 1
fi
