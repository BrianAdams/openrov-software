#!/bin/bash
# docker run -t --rm --privileged -e "BUILD_NUMBER=0" -e "REAL_GIT_BRANCH=master" -v `pwd`:/src -v `pwd`/output:/out armhfcompiler ./packageforarm.sh

set -e

# Check required env variables
if [ -z "$BUILD_NUMBER" ]; then
  echo "Set the BUILD_NUMBER environmental variable"
  exit 1
fi
if [ -z "$REAL_GIT_BRANCH" ]; then
  echo "Set the REAL_GIT_BRANCH environmental variable"
  exit 1
fi

# Install pre-reqs for this pacakge
apt-get update -qqq
apt-get install -y curl ruby-full
gem install fpm
curl -sL https://deb.nodesource.com/setup | bash -
apt-get install -y nodejs
# Use this install method to bootstrap getting to verion 2.9.0+
# the npm upgrade npm from older versions failes in qemu.
curl -L https://npmjs.org/install.sh | sh

# Double check the npm version (Must be 2.9.0 or higher)
npm --version

# Install/build the armhf version
npm install --production

cd src/static
npm install --production
npm run bower
cd ../..

# Package the results in to a deb file
  #statements
VERSION_NUMBER="`cat package.json | grep version | grep -o '[0-9]\.[0-9]\.[0-9]\+'`"


fpm -f -m info@openrov.com -s dir -t deb -a armhf -n openrov-cockpit -v $VERSION_NUMBER-$REAL_GIT_BRANCH.$BUILD_NUMBER.`git rev-parse --short HEAD` --description 'OpenROV Cockpit' --package /out .=/opt/openrov/cockpit
