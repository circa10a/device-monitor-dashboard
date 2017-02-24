FROM httpd:2.4.25-alpine
#Install Python
RUN apk add --no-cache python && \
    python -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip install --upgrade pip setuptools && \
    rm -r /root/.cache
#Change Working directory
WORKDIR /usr/local/apache2/htdocs/
#Delete existing files to be able to clone
RUN rm -f /usr/local/apache2/htdocs/index.html
#Clone Project
COPY . /usr/local/apache2/htdocs
#Create Cron Job
RUN (crontab -l 2>/dev/null; echo "*/5 * * * * cd /usr/local/apache2/htdocs/ && /usr/bin/python report.py &> /dev/null") | crontab - && \
#Generate Initial Report
python /usr/local/apache2/htdocs/report.py
#Start Cron Service then httpd
CMD crond && httpd-foreground
