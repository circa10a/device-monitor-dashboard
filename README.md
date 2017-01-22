# server-status-web
Python script to generate material design html report of servers' online/offline status. A cheap/fun monitoring solution.

##Screenshots
![alt text](http://i.imgur.com/fDMUnRe.png)
![alt text](http://i.imgur.com/GTHiU7f.png)

## Steps
- Have a text file with hostnames (no whitespace)
- Update the python script (variable at the top) with the path/name of your file with hostnames.
- Ensure that you run the python script from the project directory so it can find it's web dependencies
- Run `python report.py'

##Automation
- Setup a web server
- Install a new cron job to run the report periodically `python $path/to/project_directory/report.py &> /dev/null`
- Set output path in python script to write out html report to web serving directory such as `/var/www/html`
