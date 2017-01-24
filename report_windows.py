#!/usr/bin/python

#This script runs on mac/linux/unix

#os needed for ping command
import os
#datetime needed for timestamps
import datetime

#put the path to the file with your hostnames
names_list = "hostnames.txt"

#put the path that you would like the report to be written to
output_file_name = "status.html"

#html template
template_file = "template/template.html"

#How many seconds to refresh the page
refresh_rate = "60"

#Determine time for timestamp
today = (datetime.datetime.now())
now = today.strftime("%m/%d/%Y %H:%M:%S")

#floats needed to determine accurate percentage
servers_up = 0.00
servers_down = 0.00
servers_percent = 0.00

#this section pings the servers in the list and determines on/offline status
with open(names_list, "r") as ins:
    array = []
    for servername in ins:
        array.append(servername)
        if os.system("ping -n 1 " + servername) == 0:
            servers_up += 1
        else:
            servers_down += 1

#determine percentage of servers that are online
server_total = (servers_up + servers_down)
servers_percent = str(round((((server_total) - servers_down) / (server_total)), 2))

# empty status.html
f = open(output_file_name, "w")
f.close()

#write static lines from html file
f = open(output_file_name, "r+")
f.writelines([l for l in open(template_file).readlines()])
f.close()

#fill in "refresh_rate"
f = open(output_file_name, "r+")
content = f.read()
f.seek(0)
f.truncate()
f.write(content.replace("#REFRESHRATE", refresh_rate))
f.close()

#fill in "servers_percent"
f = open(output_file_name, "r+")
content = f.read()
f.seek(0)
f.truncate()
f.write(content.replace("#SERVERSPERCENT", servers_percent))
f.close()

#fill in "now"
f = open(output_file_name, "r+")
content = f.read()
f.seek(0)
f.truncate()
f.write(content.replace("#NOW", now))
f.close()

#this section generates the html table
html_file = open(output_file_name, "a")
with open(names_list, "r") as ins:
    array = []
    for servername in ins:
        array.append(servername)
        response = os.system("ping -n 1 "+ servername)

        if response == 0:
            html_file.write("\n		<tr>\n")
            html_file.write("		<td class=\"text-left\">" + (servername) + "</td>")
            html_file.write("\n		<td class=\"green\">Online</td>\n		</tr>")
        else:
            html_file.write("\n		<tr>\n")
            html_file.write("		<td class=\"text-left\">" + (servername) + "</td>")
            html_file.write("\n		<td class=\"red\">Offline</td>\n		</tr>")

html_file.write('\n	</tbody>\n	</table>\n</body>\n</html>')
