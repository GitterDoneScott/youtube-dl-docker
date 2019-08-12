FROM kolonuk/youtube-dl-docker-base

VOLUME /root/config
VOLUME /root/output

ADD start.sh /root/start.sh
ADD update.sh /root/update.sh
ADD youtube-dl-webui_kolonuk.sample /root/youtube-dl-webui_kolonuk.sample

RUN chmod 755 /root/start.sh
RUN chmod 755 /root/update.sh

# Get Dockerize for configuration templating TODO remove --no-check-certificate
RUN set -ex \
    && wget --no-check-certificate -nv -O dockerize.tar.gz \
        "https://github.com/jwilder/dockerize/releases/download/v${DOCKERIZE_VERSION}/dockerize-alpine-linux-amd64-v${DOCKERIZE_VERSION}.tar.gz" \
    && tar -C /usr/local/bin -xzvf dockerize.tar.gz \
    && chmod +x "/usr/local/bin/dockerize" \
    && rm dockerize.tar.gz

LABEL issues_youtube-dl="Comments/issues for youtube-dl: https://github.com/rg3/youtube-dl/issues"
LABEL issues_youtube-dl-webui="Comments/issues for youtube-dl: https://github.com/d0u9/youtube-dl-webui/issues"

EXPOSE 8282

ENTRYPOINT ["/bin/bash", "/root/start.sh"]
