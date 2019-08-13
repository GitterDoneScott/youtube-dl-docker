FROM kolonuk/youtube-dl-docker-base

LABEL issues_youtube-dl="Comments/issues for youtube-dl: https://github.com/rg3/youtube-dl/issues"
LABEL issues_youtube-dl-webui="Comments/issues for youtube-dl: https://github.com/d0u9/youtube-dl-webui/issues"

ENV CONFIG_FOLDER=/root/config \
    DOCKERIZE_VERSION=0.6.1 \
    YOUTUBE_DL_WEBUI_CONFIG="youtube-dl-webui.conf" \
    OUTPUT_FOLDER=/root/output \
    YOUTUBE_DL_WEBUI_PORT=8282 \
    YOUTUBE_DL_FORMAT="bestvideo[ext=mp4]/best[ext=mp4]/best"

VOLUME ${OUTPUT_FOLDER}

# Get Dockerize for configuration templating TODO remove --no-check-certificate
RUN set -ex \
    && wget --no-check-certificate -nv -O dockerize.tar.gz \
        "https://github.com/jwilder/dockerize/releases/download/v${DOCKERIZE_VERSION}/dockerize-alpine-linux-amd64-v${DOCKERIZE_VERSION}.tar.gz" \
    && tar -C /usr/local/bin -xzvf dockerize.tar.gz \
    && chmod +x "/usr/local/bin/dockerize" \
    && rm dockerize.tar.gz

ADD start.sh "/root/start.sh"
ADD update.sh "/root/update.sh"
ADD "${YOUTUBE_DL_WEBUI_CONFIG}.tmpl" "${CONFIG_FOLDER}/${YOUTUBE_DL_WEBUI_CONFIG}.tmpl"

RUN chmod 755 "/root/start.sh"
RUN chmod 755 "/root/update.sh"

EXPOSE ${YOUTUBE_DL_WEBUI_PORT}

ENTRYPOINT ["/bin/bash", "/root/start.sh"]
