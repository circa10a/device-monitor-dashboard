#!/bin/bash
apachedir="/var/www/html"
gitproject="https://github.com/circa10a/Device-Monitor-Dashboard.git"
project="monitor"
workdir=$(pwd)

echo
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

func_node () {
echo "Node.js version is:"
node -v
echo "npm version is:"
npm -v
if [ $? == 0 ]; then
	echo
else
	echo "Node.js not installed"
	echo "Exiting..."
	sleep 5
	exit 1
fi

echo "Installing http-server"
sleep 3
npm install http-server -g
if [ $? == 0 ]; then
  echo
	echo "http-server installed."
else
  echo
	echo "http-server not installed"
	echo "Exiting..."
	sleep 5
	exit 1
fi

echo "Cloning project in 5 seconds"
echo
sleep 5
sleep 3
git clone $gitproject $workdir/$project
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
	 echo $input >> $workdir/$project/hostnames.txt
fi
done

if [ $? == 0 ]; then
	echo
	echo "hostnames.txt created successfully in $workdir/$project"
else
	echo "writing hostnames.txt failed"
fi

echo
echo "Would you like to setup a cronjob that runs the monitor every 15 minutes? (y/n)"
echo
read input
  if [ "$input" == "y" ]; then
  	(crontab -l 2>/dev/null; echo "*/15 * * * * cd $workdir/$project/ && /usr/bin/python report.py &> /dev/null") | crontab -
    (crontab -l 2>/dev/null; echo "@reboot cd $workdir/$project/ && http-server . -s & &> /dev/null") | crontab -
	echo
	echo "Crontab installed"
	echo
	sleep 3
	echo "Check it out"
	crontab -l
	sleep 5
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

echo "Starting Node.js webserver on port 8080"

http-server $workdir/$project -s &

if [ $? == 0 ]; then
	echo "Server started successfully"
else
	echo "Server did not start successfully"
fi

echo
echo
echo "You're all set! Installation Completed successfully"
echo
echo "If you set up Cron, your web page will be ready in 15 minutes"
echo "You can access your dashboard at http://$(ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://'):8080/monitor"
echo "You an also update the devices you would like to monitor by editing $workdir/$project/hostnames.txt"
}

func_apache () {
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

if [ -d $apachedir ]; then
	echo "Apache detected"
	echo "Cloning project in 5 seconds"
	echo
	sleep 5
	sleep 3
	git clone $gitproject $apachedir/$project
	chown -R www-data:www-data $apachedir/$project
else
	echo "/var/www/html no detected"
	sleep 3
	echo
	echo "Exiting..."
	sleep 3
	exit 1
fi

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
echo
echo
echo "You're all set! Installation Completed successfully"
echo
echo "If you set up Cron, your web page will be ready in 15 minutes"
echo "You can access your dashboard at http://$(ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://')/monitor"
echo "You an also update the devices you would like to monitor by editing $apachedir/$project/hostnames.txt"
}

echo "IOT-Monitor-Dashboard install script has started successfully"
echo
echo "Either Node.js/Apache and Python are requirements to deploy IOT-Monitor-Dashboard"
echo
sleep 3
echo "Would you like to deploy with Node.js or Apache?"
echo "Enter \"n\" for Node or \"a\" for Apache."

read answer
  if [ "$answer" == "n" ]; then
  echo "Node.js selected."
	sleep 3
	echo
  func_node
elif [ "$answer" == "a" ]; then
	echo "Apache selected."
	sleep 3
	echo
  func_apache
 else
	echo "Unrecognized input. Bye"
	exit 1
fi
