#!/vendor/bin/sh
#
#
# Copyright (C) Intel 2015
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This script is used to link /data/misc/logd/logcat.xxx to /data/logs/aplog.xxx
# to persistently save android aplication log and kernel log.

APLOG_FILE_PATH=/data/logs/aplogs/aplog.
LOGCAT_FILE_PATH=/data/misc/logd/logcat.
LINK_TOOL=/vendor/bin/ln
VENDOR_PRINTF=/vendor/bin/printf
APLOG_LIMIT=$(( $( /vendor/bin/getprop persist.logd.logpersistd.count ) +1 ))
APLOG_BIT=$(( $APLOG_LIMIT / 10 ))
start_link() {
	NUM=256
	i=0

	while [ ! -e "/data/misc/logd/logcat" ]
	do
		sleep 1
	done
	[ -h /data/logs/aplogs/aplog ] || $LINK_TOOL -s /data/misc/logd/logcat /data/logs/aplogs/aplog
	while true
	do
		i=$(($i+1))
		N=$($VENDOR_PRINTF "%0"$APLOG_BIT"d" $i)
		echo "vendor.aplog: create aplog.$N"
		[ $i -eq $APLOG_LIMIT ] && exit 0
		if [ -f $LOGCAT_FILE_PATH$N ]; then
			if [ ! -h $APLOG_FILE_PATH$N ]; then
				$LINK_TOOL -s $LOGCAT_FILE_PATH$N $APLOG_FILE_PATH$N
			else
				continue
			fi
		else
			sleep 3
			i=$(($i-1))
			continue
		fi
	done
}


start_link
exit 0
