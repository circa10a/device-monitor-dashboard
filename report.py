#!/usr/bin/python

import os
import datetime
import sys
import platform
import socket


def pinghost(hostname):
    # Check os type to determine which ping command to use
    os_type = platform.platform()
    if "Windows" in os_type:
        response = os.system("ping -n 1 {0}".format(hostname))
    else:
        response = os.system("ping -c 1 {0}".format(hostname))
    return True if response == 0 else False


def checksock(hostname, port):
    if not isinstance(port, int):
        try:
            port = int(port)
        except ValueError:
            print('Port number is not numeric!')
            sys.exit()
    try:
        socket.create_connection((hostname, port), 2)
        return True
    except socket.error:
        print('%s failed on port: %s' % (hostname, str(port)))
        return False


def parsehost(hostfile):
    servers = []
    with open(hostfile, "r") as ins:
        for servername in ins:
            # strip leading/trailing whitespaces and newlines
            servername = servername.strip()
            # remove additional spaces
            servername = servername.replace(" ", "")
            # check if port is defined
            if ',' in servername:
                # create list that is servername, port number, custom name
                servername = servername.split(",")
                hostname = servername[0]
                try:
                    port = int(servername[1])
                except ValueError:
                    print("%s Port: %s is not a number!" % (hostname, servername[1]))
                    sys.exit()

                try:
                    name = servername[2]
                except IndexError:
                    print("No name")
                    sys.exit()

                servers.append({"hostname": hostname, "port": port, "name": name})
            else:
                servers.append({"hostname": servername, "port": None, "name": None})
    return servers


def createhtml(output_file_name, template_file, host_dict):
    refresh_rate = "60"
    today = (datetime.datetime.now())
    now = today.strftime("%m/%d/%Y %H:%M:%S")
    servers_up = 0.00
    servers_down = 0.00
    servers_percent = 0.00
    for h in host_dict:
        if h.get("status") == "up":
            servers_up += 1
        else:
            servers_down += 1
    server_total = (servers_up + servers_down)
    servers_percent = str(round((((server_total) - servers_down) / (server_total)), 2))
    # empty status.html
    f = open(output_file_name, "w")
    f.close()

    # write static lines from html file
    f = open(output_file_name, "r+")
    f.writelines([l for l in open(template_file).readlines()])
    f.close()

    # fill in "refresh_rate"
    f = open(output_file_name, "r+")
    content = f.read()
    f.seek(0)
    f.truncate()
    f.write(content.replace("#REFRESHRATE", refresh_rate))
    f.close()

    # fill in "servers_percent"
    f = open(output_file_name, "r+")
    content = f.read()
    f.seek(0)
    f.truncate()
    f.write(content.replace("#SERVERSPERCENT", servers_percent))
    f.close()

    # fill in "now"
    f = open(output_file_name, "r+")
    content = f.read()
    f.seek(0)
    f.truncate()
    f.write(content.replace("#NOW", now))
    f.close()
    html_file = open(output_file_name, "a")
    for h in host_dict:
        if h.get("status") == "up" and h.get("port") is not None:
            html_file.write("\n		<tr>\n")
            html_file.write("		<td onClick=\"window.open(\'http://" + (h.get("hostname")) + ":" + str(h.get("port")) + "\')\";" + "class=\"text-left\">" + (h["name"]) + ":" + str(h.get("port")) + "</td>")
            html_file.write("\n		<td><div class=\"led-green\"></div></td>")
        elif h.get("status") == "up":
            html_file.write("\n		<tr>\n")
            html_file.write("		<td onClick=\"window.open(\'http://" + (h.get("hostname")) + "\')\";"+ "class=\"text-left\">" + (h.get("hostname")) + "</td>")
            html_file.write("\n		<td><div class=\"led-green\"></div></td>")
        elif h.get("status") == "down" and h.get("port") is not None:
            html_file.write("\n		<tr>\n")
            html_file.write("		<td onClick=\"window.open(\'http://" + (h.get("hostname")) + ":" + str(h.get("port")) + "\')\";"+ "class=\"text-left\">" + (h.get("hostname")) + " port: " + str(h.get("port")) + "</td>")
            html_file.write("\n		<td><div class=\"led-red\"></div></td>")
        elif h.get("status") == "down":
            html_file.write("\n		<tr>\n")
            html_file.write("		<td onClick=\"window.open(\'http://" + (h.get("hostname")) + "\')\";" + "class=\"text-left\">" + (h.get("hostname")) + "</td>")
            html_file.write("\n		<td><div class=\"led-red\"></div></td>")
    html_file.write('\n	</tbody>\n	</table>\n</body>\n</html>')


def main():
    names_list = "hostnames.txt"
    # put the path that you would like the report to be written to
    output_file_name = "index.html"
    # html template
    template_file = "template/template.html"
    hosts = parsehost(names_list)
    for h in hosts:
        if h.get("port"):
            alive = checksock(h.get("hostname"), h.get("port"))
        else:
            alive = pinghost(h.get("hostname"))
        if alive:
            h.update(status="up")
        else:
            h.update(status="down")
    createhtml(output_file_name, template_file, hosts)


if __name__ == "__main__":
    main()
