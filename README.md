# server-status-web
Python script to generate material design html report of servers' online/offline status. A cheap/fun monitoring solution.
This can be used for for servers, networking equipment, anything that's "pingable".  

##Screenshots
![alt text](http://i.imgur.com/21lF9tC.png)
![alt text](http://i.imgur.com/PY1DsXD.png)

## Steps
- Have a text file with hostnames or ip addresses
- Update the python script (variable at the top) with the path/name of your file with hostnames.
- Ensure that you run the python script from the project directory so it can find it's web dependencies
- Run `python report.py'

##Automation
- Setup a web server
- Install a new cron job to run the report periodically `python $path/to/project_directory/report.py &> /dev/null`
- Set output path in python script to write out html report to web serving directory such as `/var/www/html`
- BE SURE TO HAVE TO HAVE THE HTML FILE IN THE ROOT OF THE PROJECT DIRECTORY

