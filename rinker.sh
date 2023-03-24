#!/bin/bash

##################################################################
## ChangeIP.com bash update script                              ##
##################################################################
## Written 3/18/09 by Tom Rinker, released to the Public Domain ##
## Updated 2/24/21 by ChangeIP, released to the Public Domain 
## updated 20/03/23 by changeip Admin-Ashton Arlo
##################################################################
## This is a simple bash script to preform a dDNS update with   ##
## ChangeIP.com. It uses only bash, wget, & curl, and so should ##
## be compatible with virtually any UNIX/Linux based system     ##
## with bash. It is intended to be executed as a cron job, and  ##
## will only execute an update of dDNS records when the IP      ##
## address changes. As ChangeIP.com dDNS records have a 5 min   ##
## Time-To-Live, it is basically pointless and wasteful to      ##
## execute it more often than every 5 minutes. This script      ##
## supports logging all activity, in 3 available log levels,    ##
## and supports simple management of log file size.             ##
##################################################################
## To use this script:                                          ##
## 1) set the variables in the script below                     ##
## 2) execute the script as a cron job                          ##
##################################################################
## WARNING: This script has two potential security holes.       ##
## First, the username and password are stored plaintext in     ##
## the script, so a system user who has read access to the      ##
## script could read them. This risk can be mitigated with      ##
## careful use of file permissions on the script.               ##
## Second, the username and password will show briefly to other ##
## users of the system via ps, w, or top. This risk can be      ##
## mitigated by moving the username and password to .wgetrc     ##
## This level of security is acceptable for some installations  ##
## including my own, but may be unacceptable for some users.    ##
##################################################################
## Note: You must configure your update hosts to be set 1 or    ##
## set 2 within DNS Manager in your client area.                ##
##################################################################

################ Script Variables ###############################
IPPATH=/tmp/IP               
TMPIP=/tmp/tmpIP
LOGPATH=/tmp/changeip.log
TEMP=/tmp/temp
CIPUSER=                   # USERNAME
CIPPASS=                   # PASSWORD
CIPSET=1                      # DDNS SET 1 or 2
LOGLEVEL=2
LOGMAX=500
#################################################################

curl -sX GET https://ip.changeip.com |head -1 > $TMPIP
# compare $IPPATH with $TMPIP, and if different, execute update
if diff $IPPATH $TMPIP > /dev/null
  then                                # same IP, no update
      if [ $LOGLEVEL -eq 2 ]
        then                          # if verbose, log no change
          echo "--------------------------------" >> $LOGPATH
          date >> $LOGPATH             
          echo "No Change" >> $LOGPATH
          echo -e "IP: \c" >> $LOGPATH
          cat $IPPATH >> $LOGPATH
          #cat $LOGPATH |tail -5
      fi
  else                                # different IP, execute update
      curl -s -AX "rinker.sh" -o $TEMP GET "https://nic.changeip.com/nic/update?u=$CIPUSER&p=$CIPPASS&myip=$(< $TMPIP)&hostname=$HOST&set=$CIPSET"
      if [ $LOGLEVEL -ne 0 ]
        then                          # if logging, log update
          echo "--------------------------------" >> $LOGPATH
          date >> $LOGPATH             
          echo "Updating" >> $LOGPATH
          echo -e "NewIP: \c" >> $LOGPATH
          cat $LOGPATH
          cat $TMPIP >> $LOGPATH
          if [ $LOGLEVEL -eq 2 ]
            then                      # verbose logging
              echo -e "OldIP: \c" >> $LOGPATH
              cat $IPPATH >> $LOGPATH
              cat $TEMP >> $LOGPATH   # log the ChangeIP.com update reply
              #cat $LOGPATH |tail -5
          fi
      fi
      cp $TMPIP $IPPATH               # Store new IP
fi

# if $LOGMAX not equal to 0, reduce log size to last $LOGMAX number of lines
if [ $LOGMAX -ne 0 ]
  then
      tail -n $LOGMAX $LOGPATH > $TEMP
      cp $TEMP $LOGPATH
      #cat $LOGPATH |tail -5
fi
