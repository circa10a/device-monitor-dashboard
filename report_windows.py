#needed to determine OS to run the correct ping command
import os

#put the path to the file with your hostnames
names_list = "file.txt"
#put the path that you would like the report to be written to
output_file_name = "status.html"

#floats needed to determine accurate percentage
servers_up=0.00
servers_down=0.00
servers_percent=0.00

#this section determines which command to run and the count of how many servers are online
with open(names_list, "r") as ins:
    array = []
    for servername in ins:
        array.append(servername)
        response = os.system("ping -n 1 "+ servername)
        if response == 0:
            servers_up += 1
        else:
            servers_down += 1

#determine percentage of servers that are online
server_total = (servers_up + servers_down)
servers_percent=(((server_total) - servers_down) / (server_total))
servers_percent=round(servers_percent,2)
servers_percent=str(servers_percent)

#begin writing the file
html_file = open(output_file_name,"w",0)
html_file.write("<html>")
html_file.write("\n")
html_file.write("<head>")
html_file.write("\n")
html_file.write("<link rel=\"stylesheet\" href=\"css/styles.css\">")
html_file.write("\n")
html_file.write("<script type=\"text/javascript\" src=\"js/jquery.min.js\"></script>")
html_file.write("\n")
html_file.write("<script type=\"text/javascript\" src=\"js/circle-progress.js\"></script>")
html_file.write("\n")
html_file.write("<script type=\"text/javascript\" src=\"js/jquery.noty.packaged.min.js\"></script>")
html_file.write("\n")
html_file.write("</head>")
html_file.write("\n")
html_file.write("<body>")
html_file.write("\n")
html_file.write("<div id=\"circle\"></div>")
html_file.write("\n")
html_file.write("<script>")
html_file.write("\n")
html_file.write("$(\'#circle\').circleProgress({")
html_file.write("\n")
html_file.write("value: " + (servers_percent) + ",")
html_file.write("\n")
html_file.write("size: 350,")
html_file.write("\n")
html_file.write("thickness: 10,")
html_file.write("\n")
html_file.write("emptyFill: \"#262b33\",")
html_file.write("\n")
html_file.write("fill: { color: [\"#0277BD\"]}});")
html_file.write("\n")
html_file.write("</script>")
html_file.write("\n")
html_file.write("<script type=\"text/javascript\" src=\"js/notifications.js\"></script>")
html_file.write("\n")
html_file.write("<body>")
html_file.write("\n")
html_file.write("<div class=\"table-title\">")
html_file.write("\n")
html_file.write("<h3> </h3>")
html_file.write("\n")
html_file.write("</div>")
html_file.write("\n")
html_file.write("<table class=\"table-fill\">")
html_file.write("\n")
html_file.write("<thead>")
html_file.write("\n")
html_file.write("<tr>")
html_file.write("\n")
html_file.write("<th class=\"text-left\">Server</th>")
html_file.write("\n")
html_file.write("<th class=\"text-left\">Status</th>")
html_file.write("\n")
html_file.write("</tr>")
html_file.write("\n")
html_file.write("</thead>")
html_file.write("\n")
html_file.write("<tbody class=\"table-hover\">")

#this section generates the html table
with open(names_list, "r") as ins:
    array = []
    for servername in ins:
        array.append(servername)
        response = os.system("ping -n 1 "+ servername)

        if response == 0:
            html_file.write("<tr>")
            html_file.write("\n")
            html_file.write("<td class=\"text-left\">" + (servername) + "</td>")
            html_file.write("\n")
            html_file.write("<td class=\"green\">Online</td>")
            html_file.write("\n")
            html_file.write("</tr>")
        else:
            html_file.write("<tr>")
            html_file.write("\n")
            html_file.write("<td class=\"text-left\">" + (servername) + "</td>")
            html_file.write("\n")
            html_file.write("<td class=\"red\">Offline</td>")
            html_file.write("\n")
            html_file.write("</tr>")
html_file.write("\n")
html_file.write("</tbody>")
html_file.write("\n")
html_file.write("</table>")
html_file.write("\n")
html_file.write("</body>")
html_file.write("\n")
html_file.write("</html>")
html_file.close()
