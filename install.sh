#!/bin/bash -eu

nginxdir="/var/www/html"
gitproject="https://github.com/circa10a/Device-Monitor-Dashboard.git"
project="monitor"

func_python() {
  echo
  if command -v python -V >/dev/null; then
    $green
    echo "Python already Installed"
    $reset
    echo
    if command -v pip --version >/dev/null; then
      $green
      echo "Pip already Installed"
      $reset
    else
      $red
      echo "Pip not installed"
      $yellow
      echo "Would you like to install it(y/n)? (must be root)"
      $reset
      read answer
      if [ "$answer" == "y" ]; then
        if is_root; then
          :
        else
          apt-get update
          apt-get install python-pip -y
          pip install jinja2
        fi
      elif [ "$answer" == "n" ]; then
        $red
        echo "Pip needs to be installed before continuing. Exiting..."
        $reset
        exit 1
      else
        $red
        echo "Unrecognized input. Bye"
        $reset
        exit 1
      fi
    fi

  else
    $red
    echo "Python not installed"
    $yellow
    echo "Would you like to install it(y/n)? (must be root)"
    $reset
    read answer
    if [ "$answer" == "y" ]; then
      if is_root; then
        apt-get update
        apt-get install python -y
      else
        :
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

func_nginx() {
  echo
  if command -v nginx >/dev/null; then
    $green
    echo "Nginx already Installed"
    $reset
  else
    $red
    echo "Nginx not installed"
    $yellow
    echo "Would you like to install it(y/n)? (must be root)"
    $reset
    read answer
    if [ "$answer" == "y" ]; then
      if is_root; then
        apt-get update
        apt-get install nginx -y
      else
        :
      fi
    elif [ "$answer" == "n" ]; then
      $red
      echo "Nginx needs to be installed before continuing. Exiting..."
      $reset
      exit 1
    else
      $red
      echo "Unrecognized input. Bye"
      $reset
      exit 1
    fi
  fi

  if [ -d $nginxdir ]; then
    $green
    echo "Nginx Directory detected"
    echo "Cloning project in 5 seconds"
    $reset
    echo
    sleep 5
    sleep 3
    git clone $gitproject $nginxdir/$project
    chmod -R 755 $nginxdir/$project
  else
    $red
    echo "${nginxdir} not found"
    sleep 3
    echo
    echo "Exiting..."
    $reset
    sleep 3
    exit 1
  fi
  cat /dev/null >$nginxdir/$project/hostnames.txt
  $yellow
  echo
  echo "Enter the hostnames or ip addresses you would like to monitor"
  echo "One by one and pressing enter after the name/address with an alias."
  echo "3 fields required, Example:"
  echo
  echo "www.google.com, 443, Google"
  echo "192.168.1.100, 3306, MySQL"
  echo
  echo "When your list is complete type \"done\""
  echo
  $reset

  while [[ $input != "done" ]]; do
    read input
    if [ "$input" == "done" ]; then
      break
    else
      echo $input >>$nginxdir/$project/hostnames.txt
    fi
  done

  if [ $? == 0 ]; then
    echo
    $green
    echo "hostnames.txt created successfully in $nginxdir/$project"
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
      echo "*/5 * * * * cd $nginxdir/$project/ && /usr/bin/python report.py &> /dev/null"
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
  echo "If you didn't setup cron, you will need to go to $nginxdir/$project and run \"python report.py\""
  echo "You can access your dashboard at http://$(ifconfig eth0 2>/dev/null | awk '/inet addr:/ {print $2}' | sed 's/addr://')/monitor"
  echo "You an also update the devices you would like to monitor by editing $nginxdir/$project/hostnames.txt"
  $reset
}

is_root() {
  if [ "$(id -u)" != "0" ]; then
    echo
    $red
    echo "Must be root to install packages..."
    $reset
    exit 1
  else
    return 0
  fi
}

if_ubuntu() {
  if command -v apt-get >/dev/null; then
    apt-get update apt-get >/dev/null
  else
    $red
    "This script only works on debian/ubuntu."
    $reset
    exit 1
  fi
}

##############
# Begin Script
##############
red="tput setaf 1"
green="tput setaf 2"
yellow="tput setaf 3"
reset="tput sgr0"

if_ubuntu

$green
echo "######################################"
echo "# Device-Monitor-Dashboard Easy Install #"
echo "#######################################"
echo
$yellow
echo "Nginx is required to deploy IOT-Monitor-Dashboard via Easy-Install."
echo "This script can install packages for you, but you must be root."
echo "Alternatively, you can use docker, please see https://github.com/circa10a/Device-Monitor-Dashboard"
echo
sleep 3
$reset

if is_root; then
  echo "You are running as root"
else
  echo "You are not root"
  echo "You are $(whoami)"
fi

func_python
sleep 5

$green
echo "Deploying with Nginx..."
func_nginx
$reset

exit 0
