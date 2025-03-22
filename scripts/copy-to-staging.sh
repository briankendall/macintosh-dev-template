#!/bin/sh

build_dir=$1
project_name=$2
disk_image=$build_dir/$project_name.dsk
staging_dir=$MACINTOSH_FTP_STAGING_PATH

if [ -z "$staging_dir" ]; then
    echo ...skipping staging, MACINTOSH_FTP_STAGING_PATH is not defined
    exit 0
fi

if [ ! -d "$staging_dir" ]; then
    echo ...skipping staging, $MACINTOSH_FTP_STAGING_PATH does not exist
fi

hmount $disk_image > /dev/null
ret=$?
if [ $ret -ne 0 ]; then
	echo hmount failed!
    exit 1
fi

hcopy -m $project_name "$staging_dir/$project_name"
ret=$?
if [ $ret -ne 0 ]; then
	echo hcopy failed!
    exit 1
fi

humount
ret=$?
if [ $ret -ne 0 ]; then
	echo humount failed!
    exit 1
fi
