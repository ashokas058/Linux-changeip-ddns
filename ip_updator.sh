#! /bin/bash
MYIP=$(curl -sX GET https://ip.changeip.com |head -1)
status=""

#---------------- Changeip credentionls ---------------------------

USER= #username
PASSWORD=  #password
HOST= #hostname

#--------------------------------------------------------------------
if [[ $(cat /var/run/last.ip) != $(echo $MYIP) ]];then
  	status=($(curl -s -X GET "https://nic.ChangeIP.com/nic/update?u=$USER&p=$PASSWORD&myip=$MYIP&hostname=$HOST&set=1"):1:3)
  	if [[ $status == "200" ]];then
		echo "New IP updated:- $MYIP"
		echo $MYIP > /var/run/last.ip
		echo "Success --- $(date '+%Y-%m-%d %H:%M')----- $MYIP\n" >> /var/log/changeip.log
	else
		echo "status code :- $status"
		echo "Error --- $(date '+%Y-%m-%d %H:%M')----- $MYIP\n" >> /var/log/changeip.log
		echo "IP:- $MYIP"
	fi
else
	echo "same IP --------switching  to sleep Mode "
fi

sleep 30s
NEWIP=$(dig $HOST | tail -n 9 | grep $HOST | cut -f5)
if [ "$MYIP" != "$NEWIP" ]
	then rm /var/run/last.ip
fi
exit 0
