#!/bin/bash

forced=${1:?"no"};shift

# add virtualenv to path
export PATH=$PATH:/root/.virtualenvs/pelican/bin

mkdir -p /var/www/blogduyax >/dev/null

cd /usr/local/src/blogduyax

if [[ "$forced" = "no" ]] ; then
    echo "Pelican is checking if publishing is needed..."
    git fetch origin
    reslog=$(git log HEAD..origin/master --oneline)
    if [[ "${reslog}" = "" ]] ; then
        echo "Repository has not changed. Nothing to do"
        exit 0
    else
        echo "Repository has changed. Merge master branch"
        git merge origin/master
    fi
fi

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
