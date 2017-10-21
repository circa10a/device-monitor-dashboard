#!/bin/bash -eu

apachedir="/var/www/html"
gitproject="https://github.com/circa10a/Device-Monitor-Dashboard.git"
project="monitor"
workdir=$(pwd)

func_python() {
  echo
  if command -v python > /dev/null; then
    $green
    echo "Python already Installed"
    $reset
  else
    $red
    echo "Python not installed"
    $yellow
    echo "Would you like to install it(y/n)? (must be root)"
    $reset
    read answer
    if [ "$answer" == "y" ]; then
      if [ "$(id -u)" != "0" ]; then
        echo
        $red
        echo "Must be root to install packages..."
        $reset
        exit 1
      elif [ "$(id -u)" == "0" ]; then
        apt-get update
        apt-get install python -y
      fi
    elif [ "$answer" == "n" ]; then
      $red
      echo "Python needs to be installed before continuing. Exiting..."
      $reset
      exit 1
    else
      $red
      echo "Unrecognized input. Bye"
      $reset
      exit 1
    fi
  fi
}

func_node() {
  if command -v node > /dev/null; then
    $green
    echo "Node already Installed"
    $reset
  else
    $red
    echo "Node not installed"
    $yellow
    echo "Would you like to install it(y/n)? (must be root)"
    $reset
    read answer
    if [ "$answer" == "y" ]; then
      if [ "$(id -u)" != "0" ]; then
        echo
        $red
        echo "Must be root to install packages..."
        $reset
        exit 1
      elif [ "$(id -u)" == "0" ]; then
        apt-get update
        apt-get install -y nodejs-legacy npm
        $green
        echo "Installing http-server"
        $reset
        sleep 3
        if npm install http-server -g; then
          npm install http-server -g
          echo
          $green
          echo "http-server installed."
          $reset
        else
          echo
          $red
          echo "http-server not installed"
          echo "Exiting..."
          $reset
          sleep 3
          exit 1
        fi
      fi
    elif [ "$answer" == "n" ]; then
      $red
      echo "Node needs to be installed before continuing. Exiting..."
      $reset
      exit 1
    else
      $red
      echo "Unrecognized input. Bye"
      $reset
      exit 1
    fi
  fi

  $green
  echo "Cloning project in 5 seconds"
  $reset
  echo
  sleep 5
  git clone $gitproject $workdir/$project
  echo
  cat /dev/null >$workdir/$project/hostnames.txt
  echo
  $yellow
  echo "Enter the hostnames or ip addresses you would like to monitor"
  echo "One by one and pressing enter after the name/address."
  echo "Ex. www.google.com"
  echo "For port monitoring, Ex. www.google.com, 80"
  echo "When your list is complete type \"done\""
  echo
  $reset
  
  while [[ $input != "done" ]]; do
    read input
    if [ "$input" == "done" ]; then
      break
    else
      echo $input >>$workdir/$project/hostnames.txt
    fi
  done

  if [ $? == 0 ]; then
    echo
    $green
    echo "hostnames.txt created successfully in $workdir/$project"
    $reset
  else
    $red
    echo "writing hostnames.txt failed"
    $reset
  fi

  $yellow
  echo
  echo "Would you like to setup a cronjob that runs the monitor every 5 minutes? (y/n)"
  echo
  $reset
  read input
  if [ "$input" == "y" ]; then
    (
      crontab -l 2>/dev/null
      echo "*/5 * * * * cd $workdir/$project/ && /usr/bin/python report.py &> /dev/null"
    ) | crontab -
    (
      crontab -l 2>/dev/null
      echo "@reboot cd $workdir/$project/ && http-server . -s & &> /dev/null"
    ) | crontab -
    echo
    $green
    echo "Crontab installed"
    echo
    sleep 5
    echo "Check it out"
    $reset
    crontab -l
    sleep 5
    echo
  elif [ "$input" == "n" ]; then
    $green
    echo "OK, suit yourself."
    echo "You will need to run python report.py manually to generate your index.html file"
    echo "All done."
    sleep 2
    echo
    $red
    echo "Exiting..."
    $reset
  else
    $red
    echo "Unrecognized input. Bye"
    $reset
    exit 1
  fi
  
  $green
  echo "Starting Node.js webserver on port 8080"
  $reset
  http-server $workdir/$project/ -s &

  if [ $? == 0 ]; then
    echo
    $green
    echo "Server started successfully"
    $reset
  else
    $red
    echo "Server was unable to start"
    $reset
    exit 1
  fi

  $green
  echo
  echo "You're all set! Installation Completed successfully"
  echo
  echo "If you set up Cron, your web page will be ready in 5 minutes"
  echo "If you didn't setup cron, you will need to go to $workdir/$project and run \"python report.py\""
  echo "You can access your dashboard at http://$(ifconfig eth0 2>/dev/null | awk '/inet addr:/ {print $2}' | sed 's/addr://'):8080"
  echo "You an also update the devices you would like to monitor by editing $workdir/$project/hostnames.txt"
  $reset
}

func_apache() {
  echo
  if command -v apache2 > /dev/null; then
    $green
    echo "Apache already Installed"
    $reset
  else
    $red
    echo "Apache not installed"
    $yellow
    echo "Would you like to install it(y/n)? (must be root)"
    $reset
    read answer
    if [ "$answer" == "y" ]; then
      if [ "$(id -u)" != "0" ]; then
        echo
        $red
        echo "Must be root to install packages..."
        $reset
        exit 1
      elif [ "$(id -u)" == "0" ]; then
        apt-get update
        apt-get install apache2 -y
      fi
    elif [ "$answer" == "n" ]; then
      $red
      echo "Apache needs to be installed before continuing. Exiting..."
      $reset
      exit 1
    else
      $red
      echo "Unrecognized input. Bye"
      $reset
      exit 1
    fi
  fi

  if [ -e $apachedir ]; then
    $green
    echo "Apache Directory detected"
    echo "Cloning project in 5 seconds"
    $reset
    echo
    sleep 5
    sleep 3
    git clone $gitproject $apachedir/$project
    chown -R www-data:www-data $apachedir/$project
  else
    $red
    echo "/var/www/html not found"
    sleep 3
    echo
    echo "Exiting..."
    $reset
    sleep 3
    exit 1
  fi
  cat /dev/null >$apachedir/$project/hostnames.txt
  $yellow
  echo
  echo "Enter the hostnames or ip addresses you would like to monitor"
  echo "One by one and pressing enter after the name/address."
  echo "Ex. www.google.com"
  echo "For port monitoring, Ex. www.google.com, 80"
  echo "When your list is complete type \"done\""
  echo
  $reset

  while [[ $input != "done" ]]; do
    read input
    if [ "$input" == "done" ]; then
      break
    else
      echo $input >>$apachedir/$project/hostnames.txt
    fi
  done

  if [ $? == 0 ]; then
    echo
    $green
    echo "hostnames.txt created successfully in $apachedir/$project"
    $reset
  else
    $red
    echo "writing hostnames.txt failed"
    $reset
  fi

  $yellow
  echo
  echo "Would you like to setup a cronjob that runs the monitor every 5 minutes? (y/n)"
  $reset
  echo
  read input
  if [ "$input" == "y" ]; then
    (
      crontab -l 2>/dev/null
      echo "*/5 * * * * cd $apachedir/$project/ && /usr/bin/python report.py &> /dev/null"
    ) | crontab -
    echo
    $green
    echo "Crontab installed"
    echo
    sleep 3
    echo "Check it out"
    $reset
    crontab -l
    sleep 6
    echo
  elif [ "$input" == "n" ]; then
    $green
    echo "OK, suit yourself. All done"
    sleep 2
    echo
    echo "Exiting..."
    $reset
  else
    $red
    echo "Unrecognized input. Bye"
    $reset
    exit 1
  fi

  $green
  echo
  echo "You're all set! Installation Completed successfully"
  echo
  echo "If you set up Cron, your web page will be ready in 5 minutes"
  echo "If you didn't setup cron, you will need to go to $apachedir/$project and run \"python report.py\""
  echo "You can access your dashboard at http://$(ifconfig eth0 2>/dev/null | awk '/inet addr:/ {print $2}' | sed 's/addr://')/monitor"
  echo "You an also update the devices you would like to monitor by editing $apachedir/$project/hostnames.txt"
  $reset
}

##############
# Begin Script
##############
red="tput setaf 1"
green="tput setaf 2"
yellow="tput setaf 3"
reset="tput sgr0"

if command -v apt-get > /dev/null; then
  :
else
  $red
  "This script only works on debian/ubuntu."
  $reset
  exit 1
fi

$green
echo "#################################################################"
echo "# IOT-Monitor-Dashboard install script has started successfully #"
echo "#################################################################"
echo
$yellow
echo "Either Node.js/Apache and Python are requirements to deploy IOT-Monitor-Dashboard"
echo
echo "This script can install packages for you, but you must be root."
$reset

if [ "$(id -u)" != "0" ]; then
  echo "You are not root"
  echo "You are $(whoami)"
else
  echo "You are running as root"
fi

func_python
sleep 5

$yellow
echo "Would you like to deploy with Apache or Node.js?"
echo "Enter \"a\" for Apache or \"n\" for Node.js."
$reset

read answer
if [ "$answer" == "n" ]; then
  echo "Node.js selected."
  sleep 3
  echo
  func_node
  exit 0
elif [ "$answer" == "a" ]; then
  echo "Apache selected."
  sleep 3
  echo
  func_apache
  exit 0
else
  $red
  echo "Unrecognized input. Bye"
  $reset
  exit 1
fi
