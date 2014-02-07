#!/bin/sh


TEMP_PROFILE=`mktemp -d`
cp -r /home/psd/.config/chromium/* $TEMP_PROFILE
echo "Starting Chrome"
chromium-browser --user-data-dir=$TEMP_PROFILE --start-maximized http://my.psd401.net
echo "Chrome Closed, Removing temp dir"

rm -rf $TEMP_PROFILE

exit 0
