#!/usr/bin/bash

LOGFILE="build.log"

echo "build.sh started at $(date)\n\n" | tee $LOGFILE
mkdocs build --site-dir build --verbose --strict &>> $LOGFILE

if [[ $? -eq 0 ]]; then
	echo "\n\nTest build succeeded, committing to main \n\n" | tee -a $LOGFILE

	git add . &>> $LOGFILE
	git commit -m "build at $(date)" &>> $LOGFILE
	git push origin main &>> $LOGFILE

	echo "\n\nRunning mkdocs gh-deploy...\n\n" | tee -a $LOGFILE
	mkdocs gh-deploy --verbose --strict &>> $LOGFILE

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
