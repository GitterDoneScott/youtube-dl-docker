#!/bin/bash

echo Checking installed versions...

# Get youtube-dl version
if [[ -f /usr/local/bin/youtube-dl ]]
then
  VERSION=$(/usr/local/bin/youtube-dl --version)
fi

# Get youtube-dl-webui version
if [[ -f /usr/local/bin/youtube-dl-webui ]]
then
  VERSIONwebui=$(cat /usr/local/bin/youtube-dl-webui | grep youtube-dl-webui | grep -oP "youtube-dl-webui==\K.*?(?=')" | head -1)
fi

# Get current github release version of youtube-dl
RELEASE=$(wget -q -O - "https://api.github.com/repos/rg3/youtube-dl/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')

# Get current github release version of youtube-dl-webui
RELEASEwebui=$(wget -q -O - "https://api.github.com/repos/d0u9/youtube-dl-webui/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')

#flask release

# If no github version returned
if ( [[ "$RELEASE" == "" ]] || [[ "$RELEASEwebui" == "" ]] ) && [[ "$FORCEDOWNLOAD" -eq "" ]]
then
  #indicates something wrong with the github call
  echo ******** Warning - unable to check latest release!!  Please raise an issue https://github.com/kolonuk/youtube-dl-docker/issues/new
fi

echo youtube-dl installed version: $VERSION
echo youtube-dl released version:  $RELEASE
echo youtube-dl-webui installed version: $VERSIONwebui
echo youtube-dl-webui released version:  $RELEASEwebui

# generate youtube-dl-webui.conf from template:
echo "=> Creating youtube-dl-webui.conf config file from template..."
dockerize -template "${CONFIG_FOLDER}/youtube-dl-webui.tmpl" \
 | grep -Ev "^[[:space:]]*#|^$" \
 | uniq > "${YOUTUBE_DL_WEBUI_CONFIG}"


if [[ "$VERSION" == "" ]] || \
   [[ "$VERSION" != "$RELEASE" ]] || \
   [[ "$FORCEDOWNLOAD" != "" ]]
then
  if [[ "$RELEASE" == "" ]]
  then
    echo Getting latest version of youtube-dl...
    # No release returned from github, download manually
    wget -q https://yt-dl.org/downloads/latest/youtube-dl -O /usr/local/bin/youtube-dl
    chmod a+rx /usr/local/bin/youtube-dl
  else
    # Download and unpack release
    echo Getting latest release of youtube-dl...
    wget -q https://github.com/rg3/youtube-dl/releases/download/$RELEASE/youtube-dl-$RELEASE.tar.gz -O /root/latest.tar.gz
    tar -xzf /root/latest.tar.gz --directory /root/
    cp -f /root/youtube-dl/youtube-dl /usr/local/bin/
    rm -f /root/latest.tar.gz
    rm -Rf /root/youtube-dl
  fi
  # no need to restart youtube-dl as is a standalone program
  #RESTART=1
fi

if [[ "$VERSIONwebui" == "" ]] || \
   [[ "$VERSIONwebui" != "$RELEASEwebui" ]] || \
   [[ "$FORCEDOWNLOAD" != "" ]]
then
  if [[ "$RELEASEwebui" == "" ]]
  then
  # No release returned from github, download manually
    echo Getting latest version of youtube-dl-webui...
    wget -q https://github.com/d0u9/youtube-dl-webui/archive/master.zip -O /root/latestwebui.zip
    cd /root
    unzip latestwebui.zip
    rm -f latestwebui.zip
    cd youtube-dl-webui-master
    python setup.py -q install
    if [[ ! -f /root/config/youtube-dl-webui.conf ]]
    then
      cp /root/youtube-dl-webui_kolonuk.sample /root/config/youtube-dl-webui.conf
    fi
    rm -Rf /root/youtube-dl-webui-master
  else
    # Download and unpack release
    echo Getting latest release of youtube-dl-webui...
    wget -q https://github.com/d0u9/youtube-dl-webui/archive/$RELEASEwebui.tar.gz -O /root/latestwebui.tar.gz
    cd /root
    tar -xzf /root/latestwebui.tar.gz youtube-dl-webui-$RELEASEwebui --directory /root/
    rm -f /root/latestwebui.tar.gz
    cd youtube-dl-webui-$RELEASEwebui
    python setup.py -q install
    if [[ ! -f /root/config/youtube-dl-webui.conf ]]
    then
      cp /root/youtube-dl-webui_kolonuk.sample /root/config/youtube-dl-webui.conf
    fi
    rm -Rf /root/youtube-dl-webui-$RELEASEwebui
  fi
  RESTART=1
fi

if [[ "$RESTART" == "1" ]]
then
  # kill current youtube-dl-webui gracefully (youtube-dl will re-run next download)
  # This will kill the running perl processes, and the start script will just re-load it
  if [[ "$1" != "start" ]]
  then
    echo Killing youtube-dl-webui process...
    killall -9 python
  fi
fi
