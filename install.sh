#!/bin/bash
apachedir="/var/www/html"
gitproject="https://github.com/circa10a/Device-Monitor-Dashboard.git"
project="monitor"
workdir=$(pwd)

func_python (){
echo
if python -v &> /dev/null; then
   echo "Python already Installed"
else
   echo "Python not installed"
   echo "Would you like to install it(y/n)? (must be root)"
   read answer
   if [ "$answer" == "y" ]; then
     if [ "$(id -u)" != "0" ]; then
	echo
    	echo "Must be root to install packages..."
    	exit 1
     elif [ "$(id -u)" == "0" ]; then
	apt-get install python -y
     fi
   elif [ "$answer" == "n" ]; then
        echo "Python needs to be installed before continuing. Exiting..."
        exit 1
   else
        echo "Unrecognized input. Bye"
	exit 1
   fi
fi
}

func_node () {

if node -v &> /dev/null; then
   echo "Node already Installed"
else
   echo "Node not installed"
   echo "Would you like to install it(y/n)? (must be root)"
   read answer
   if [ "$answer" == "y" ]; then
     if [ "$(id -u)" != "0" ]; then
	echo
    	echo "Must be root to install packages..."
    	exit 1
     elif [ "$(id -u)" == "0" ]; then
	apt-get install nodejs-legacy -y
	apt-get install npm -y
	echo "Installing http-server"
	sleep 3
	if npm install http-server -g ; then
	   echo
	   echo "http-server installed."
	else
	   echo
	   echo "http-server not installed"
	   echo "Exiting..."
	   sleep 5
	   exit 1
	fi
     fi
   elif [ "$answer" == "n" ]; then
	   echo "Node needs to be installed before continuing. Exiting..."
	   exit 1
   else
	   echo "Unrecognized input. Bye"
	   exit 1
   fi
fi

echo "Cloning project in 5 seconds"
echo
sleep 5
git clone $gitproject $workdir/$project
echo
cat /dev/null > $workdir/$project/hostnames.txt
echo "Enter the hostnames or ip addresses you would like to monitor"
echo "One by one and pressing enter after the name/address."
echo "Ex. www.google.com"
echo "For port monitoring, Ex. www.google.com, 80"
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
echo "Would you like to setup a cronjob that runs the monitor every 5 minutes? (y/n)"
echo
read input
  if [ "$input" == "y" ]; then
  	(crontab -l 2>/dev/null; echo "*/5 * * * * cd $workdir/$project/ && /usr/bin/python report.py &> /dev/null") | crontab -
    (crontab -l 2>/dev/null; echo "@reboot cd $workdir/$project/ && http-server . -s & &> /dev/null") | crontab -
	echo
	echo "Crontab installed"
	echo
	sleep 5
	echo "Check it out"
	crontab -l
	sleep 5
	echo
  elif [ "$input" == "n" ]; then
	echo "OK, suit yourself."
	echo "You will need to run python report.py manually to generate your index.html file"
	echo "All done."
	sleep 2
	echo
	echo "Exiting..."
 else
	echo "Unrecognized input. Bye"
	exit 1
fi

echo "Starting Node.js webserver on port 8080"

if http-server $workdir/$project/ -s ; then
	http-server $workdir/$project/ -s &
	echo "Server started successfully"
else
	echo "Server did not start successfully"
fi

echo
echo "You're all set! Installation Completed successfully"
echo
echo "If you set up Cron, your web page will be ready in 5 minutes"
echo "If you didn't setup cron, you will need to go to $workdir/$project and run \"python report.py\""
echo "You can access your dashboard at http://$(ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://'):8080"
echo "You an also update the devices you would like to monitor by editing $workdir/$project/hostnames.txt"
}

func_apache () {
echo
if apache2 -V &> /dev/null; then
   echo "Apache already Installed"
else
   echo "Apache not installed"
   echo "Would you like to install it(y/n)? (must be root)"
   read answer
      if [ "$answer" == "y" ]; then
	if [ "$(id -u)" != "0" ]; then
	    echo
	    echo "Must be root to install packages..."
	    exit 1
	elif [ "$(id -u)" == "0" ]; then
	    apt-get install apache2 -y
	fi
      elif [ "$answer" == "n" ]; then
	    echo "Apache needs to be installed before continuing. Exiting..."
	    exit 1
      else
	   echo "Unrecognized input. Bye"
   	   exit 1
      fi
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
	echo "/var/www/html not detected"
	sleep 3
	echo
	echo "Exiting..."
	sleep 3
	exit 1
fi
cat /dev/null > $apachedir/$project/hostnames.txt
echo "Enter the hostnames or ip addresses you would like to monitor"
echo "One by one and pressing enter after the name/address."
echo "Ex. www.google.com"
echo "For port monitoring, Ex. www.google.com, 80"
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
echo "Would you like to setup a cronjob that runs the monitor every 5 minutes? (y/n)"
echo
read input
  if [ "$input" == "y" ]; then
  	(crontab -l 2>/dev/null; echo "*/5 * * * * cd $apachedir/$project/ && /usr/bin/python report.py &> /dev/null") | crontab -
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
echo "You're all set! Installation Completed successfully"
echo
echo "If you set up Cron, your web page will be ready in 5 minutes"
echo "If you didn't setup cron, you will need to go to $apachedir/$project and run \"python report.py\""
echo "You can access your dashboard at http://$(ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://')/monitor"
echo "You an also update the devices you would like to monitor by editing $apachedir/$project/hostnames.txt"
}
echo "#################################################################"
echo "  IOT-Monitor-Dashboard install script has started successfully  "
echo "#################################################################"
echo
echo "Either Node.js/Apache and Python are requirements to deploy IOT-Monitor-Dashboard"
echo
echo "This script can install packages for you, but you must be root."

if [ "$(id -u)" != "0" ]; then
   echo "You are not root"
   echo "You are $(whoami)"
else
	echo "You are running as root"
fi

func_python
sleep 5
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
