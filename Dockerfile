FROM kolonuk/youtube-dl-docker-base

VOLUME /root/config
VOLUME /root/output

ADD start.sh /root/start.sh
ADD update.sh /root/update.sh
ADD youtube-dl-webui_kolonuk.sample /root/youtube-dl-webui_kolonuk.sample

RUN chmod 755 /root/start.sh
RUN chmod 755 /root/update.sh

LABEL issues_youtube-dl="Comments/issues for youtube-dl: https://github.com/rg3/youtube-dl/issues"
LABEL issues_youtube-dl-webui="Comments/issues for youtube-dl: https://github.com/d0u9/youtube-dl-webui/issues"
LABEL issues_kolonuk/youtube-dl-docker="Comments/issues for this dockerfile: https://github.com/kolonuk/youtube-dl-docker/issues"
LABEL maintainer="John Wood <john@kolon.co.uk>"

EXPOSE 8282

ENTRYPOINT ["/bin/bash", "/root/start.sh"]
