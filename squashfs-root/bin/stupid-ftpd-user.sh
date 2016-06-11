#!/bin/sh

FTPD_FILE=/var/stupid-ftpd.conf


if [ ! -n "$3" ]; then
  echo "insufficient arguments!"
  echo "Usage: $0 <user> <passwd> <home_dir> <max_logins> <flags:D/U/O/M/E/A>"
  echo "<flags>     D - download
                    U - upload + making directories
                    O - overwrite existing files
                    M - allows multiple logins
                    E - allows erase operations
                    A - allows EVERYTHING(!)"
  exit 0
fi
eval `flash get USER_NAME`
eval `flash get USER_PASSWORD`

#FTPD_USER="$1"
#FTPD_PASSWD="$2"
FTPD_HOME_DIR="$1"
FTPD_MAX_LOGINS="$2"
FTPD_FLAGS="$3"

echo "user=$USER_NAME $USER_PASSWORD $FTPD_HOME_DIR $FTPD_MAX_LOGINS $FTPD_FLAGS"  >> $FTPD_FILE
