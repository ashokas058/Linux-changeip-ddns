#! /bin/bash
MYIP=$(curl https://ipinfo.io/ip)
echo $MYIP
USER=  #username
PASSWORD=  #password
HOST=  #hostname
if [ ! -f /var/run/last.ip ]
	then echo $MYIP > /var/run/last.ip
	curl -s -X GET "https://nic.ChangeIP.com/nic/update?u=$USER&p=$PASSWORD&myip=$MYIP&hostname=$HOST&set=1"
fi
if ! cmp -s /var/run/last.ip <(echo $MYIP)
	then  curl -s -X GET "https://nic.ChangeIP.com/nic/update?u=$USER&p=$PASSWORD&myip=$MYIP&hostname=$HOST&set=1"
	echo $MYIP > /var/run/last.ip
fi
sleep 30s
NEWIP=$(dig $HOST | tail -n 9 | grep $HOST | cut -f5)
if [ "$MYIP" != "$NEWIP" ]
	then rm /var/run/last.ip
fi
exit 0 

