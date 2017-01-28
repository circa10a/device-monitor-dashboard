#!/bin/bash
apachedir="/var/www/html"
gitproject="https://github.com/circa10a/Device-Monitor-Dashboard.git"
project="monitor"
echo "IOT-Monitor-Dashboard install script has started successfully"
echo
echo "Apache and python are requirements to deploy IOT-Monitor-Dashboard"
echo
sleep 3
echo "Apache version is:"
apache2 -v
if [ $? == 0 ]; then
	echo
else
	echo "Apache not installed"
	echo "Exiting..."
	sleep 5
	exit 1
fi
echo "Python version is:"
python -V
if [ $? == 0 ]; then
	echo
else
	echo "Python not installed"
	echo "Exiting..."
	sleep 5
	exit 1
fi
if [ -d $apachedir ]; then
	echo "Apache detected"
	echo "Cloning project in 5 seconds"
	echo
	sleep 5
	sleep 3
	git clone $gitproject $apachedir/$project
	chown -R www-data:www-data $apachedir/$project
else
	echo "No web server detected, please install Apache"
	sleep 3
	echo
	echo "Exiting..."
	sleep 3
	exit 1
fi
echo
echo
echo "Enter the hostnames or ip addresses you would like to monitor"
echo "One by one and pressing enter after the name/address."
echo  "When your list is complete type \"done\""
echo
while [[ $input != "done" ]]
do
read input
  if [ "$input" == "done" ]; then
  	break
  else
	 echo $input >> $apachedir/$project/hostnames.txt
fi
done
if [ $? == 0 ]; then
	echo
	echo "hostnames.txt created successfully in $apachedir/$project"
else
	echo "writing hostnames.txt failed"
fi
echo
echo "Would you like to setup a cronjob that runs the monitor every 15 minutes? (y/n)"
echo
read input
  if [ "$input" == "y" ]; then
  	(crontab -l 2>/dev/null; echo "*/15 * * * * cd $apachedir/$project/ && /usr/bin/python report.py &> /dev/null") | crontab -
		echo
		echo "Crontab installed"
		echo
		sleep 3
		echo "Check it out"
		crontab -l
		sleep 6
		echo
  elif [ "$input" == "n" ]; then
	 echo "OK, suit yourself. All done"
	 sleep 2
	 echo
	 echo "Exiting..."
 else
	 echo "Unrecognized input. Bye"
	 exit 1
fi
echo "You're all set! Installation Completed successfully"
echo
echo "If you set up Cron, your web page will be ready in 15 minutes"
echo "You can access your dashboard at http://$(ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://')/monitor"
