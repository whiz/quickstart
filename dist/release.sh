#!/bin/bash

REQUIRED_BASH_VERSION=3.0.0

if [[ $BASH_VERSION < $REQUIRED_BASH_VERSION ]]; then
  echo "You must use Bash version 3 or newer to run this script"
  exit
fi

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# DEFINE

VERSION_REGEX='([0-9]*)\.([0-9]*)([a-zA-Z0-9\.]*)'


# SCRIPT

usage()
{
cat << EOF
usage: $0 options

This script performs a release of the Quickstarts 

OPTIONS:
   -s      Snapshot version number to update from
   -n      New snapshot version number to update to, if undefined, defaults to the version number updated from
   -r      Release version number
EOF
}

release()
{
   echo "Regenerating html from markdown"
   $DIR/release-utils.sh -m
   echo "Releasing JBoss AS Quickstarts version $RELEASEVERSION"
   $DIR/release-utils.sh -u -o $SNAPSHOTVERSION -n $RELEASEVERSION
   git commit -a -m "Prepare for $RELEASEVERSION release"
   git tag -a $RELEASEVERSION -m "Tag $RELEASEVERSION"
   $DIR/release-utils.sh -u -o $RELEASEVERSION -n $NEWSNAPSHOTVERSION
   git commit -a -m "Prepare for development of $NEWSNAPSHOTVERSION"
   echo "Building Distribution zip"
   BRANCH=$(parse_git_branch)
   git checkout $RELEASEVERSION
   mvn clean install -f $DIR/pom.xml
   git checkout $BRANCH
   rsync -Pv --protocol=28 $DIR/target/jboss-as-quickstarts-$RELEASEVERSION-dist.zip jbossas@filemgmt.jboss.org:downloads_htdocs/jbossas/$MAJOR_VERSION.$MINOR_VERSION/jboss-as-$RELEASEVERSION
}

parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}


SNAPSHOTVERSION="UNDEFINED"
RELEASEVERSION="UNDEFINED"
NEWSNAPSHOTVERSION="UNDEFINED"
MAJOR_VERSION="UNDEFINED"
MINOR_VERSION="UNDEFINED"

while getopts “n:r:s:” OPTION

do
     case $OPTION in
         h)
             usage
             exit
             ;;
         s)
             SNAPSHOTVERSION=$OPTARG
             ;;
         r)
             RELEASEVERSION=$OPTARG
             ;;
         n)
             NEWSNAPSHOTVERSION=$OPTARG
             ;;
         [?])
             usage
             exit
             ;;
     esac
done

if [[ $RELEASEVERSION =~ $VERSION_REGEX ]]; then
   MAJOR_VERSION=${BASH_REMATCH[1]}
   MINOR_VERSION=${BASH_REMATCH[2]}
fi

if [ "$NEWSNAPSHOTVERSION" == "UNDEFINED" ]
then
   NEWSNAPSHOTVERSION=$SNAPSHOTVERSION
fi

if [ "$MAJOR_VERSION" == "UNDEFINED" -o  "$MINOR_VERSION" == "UNDEFINED" ]
then
   echo "\nUnable to extract major and minor versions\n"
   usage
   exit
fi

if [ "$SNAPSHOTVERSION" == "UNDEFINED" -o  "$RELEASEVERSION" == "UNDEFINED" ]
then
   echo "\nMust specify -r and -s\n"
   usage
   exit
fi

release

