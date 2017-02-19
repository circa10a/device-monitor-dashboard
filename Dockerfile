FROM httpd:2.4.25-alpine
#Install Python
RUN apk add --no-cache python git && \
    python -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip install --upgrade pip setuptools && \
    rm -r /root/.cache
#Change Working directory    
WORKDIR /usr/local/apache2/htdocs/
#Delete existing files to be able to clone
RUN rm -f /usr/local/apache2/htdocs/index.html && \
#Clone Project
git clone https://github.com/circa10a/Device-Monitor-Dashboard.git /usr/local/apache2/htdocs/ && \
#Start Cron Service
crond && \
#Create Cron Job
(crontab -l 2>/dev/null; echo "*/5 * * * * cd /usr/local/apache2/htdocs/ && /usr/bin/python report.py &> /dev/null") | crontab -
#Add ability to add custom user hostname file
COPY hostnames.txt /usr/local/apache2/htdocs/
#Generate Initial Report
RUN python /usr/local/apache2/htdocs/report.py
