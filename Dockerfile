FROM nginx:alpine
#Install Python
RUN apk add --no-cache python && \
    python -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip install --upgrade pip setuptools jinja2 && \
    rm -r /root/.cache
#Change Working directory
WORKDIR /usr/share/nginx/html
#Delete existing files to be able to clone
RUN rm -f /usr/share/nginx/html/index.html
#Copy Source Files
COPY . /usr/share/nginx/html
#Create Cron Job & Generate Initial Report
RUN (crontab -l 2>/dev/null; echo "*/5 * * * * cd /usr/share/nginx/html && /usr/bin/python report.py &> /dev/null") | crontab - && \
python /usr/share/nginx/html/report.py
#Start Cron Service then nginx
CMD crond && nginx -g "daemon off;"
