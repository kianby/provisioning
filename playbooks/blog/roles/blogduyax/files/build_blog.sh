#!/bin/bash

# add virtualenv to path
export PATH=$PATH:/root/.virtualenvs/pelican/bin

mkdir -p /var/www/blogduyax >/dev/null

cd /usr/local/src/blogduyax

echo "Pelican is checking if publishing is needed..."

# git pull
git fetch origin
reslog=$(git log HEAD..origin/master --oneline)
if [[ "${reslog}" = "" ]] ; then
    echo "Repository has not changed. Nothing to do"
else
    echo "Repository has changed. Merge master branch"
    git merge origin/master

    # build
    echo "Start Pelican build process"
    make publish
    RETVAL=$?
    if [ $RETVAL -ne 0 ]; then
        echo "Build failed. It is not safe to deploy"
    else
        echo "Build successful. Deploying..."
        rm -rf /var/www/blogduyax/*
        cp -r /usr/local/src/blogduyax/output/* /var/www/blogduyax/.
        chown -R www-data:www-data /var/www/blogduyax
    fi
fi
