FROM nginx:alpine

ENV NGINX_DIR /usr/share/nginx/html

WORKDIR $NGINX_DIR

RUN rm -f $NGINX_DIR/*

COPY . $NGINX_DIR

RUN apk add --no-cache python3 && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install -r requirements.txt && \
    rm -r /root/.cache

RUN (crontab -l 2>/dev/null; echo "*/5 * * * * /usr/bin/python3 report.py") | crontab - && \
python3 $NGINX_DIR/report.py

CMD crond && nginx -g "daemon off;"
