#!/bin/bash

echo Checking latest version of youtube-dl...
# Get cgi script version
if [[ -f /usr/local/bin/youtube-dl ]]
then
  VERSION=$(/usr/local/bin/youtube-dl --version)
fi

echo Checking latest version of youtube-dl-webui...
# Get main script version
#if [[ -f /root/get_iplayer ]]
#then
#  VERSIONwebui=$(cat /root/get_iplayer | grep version | grep -oP 'version\ =\ \K.*?(?=;)' | head -1)
#fi

# Get current github release version of youtube-dl
RELEASE=$(wget -q -O - "https://api.github.com/repos/rg3/youtube-dl/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')

# Get current github release version of youtube-dl-webui
#RELEASEwebui=$(wget -q -O - "https://api.github.com/repos/rg3/youtube-dl/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")')

# If no github version returned
#if ( [[ "$RELEASE" == "" ]] || [[ "$RELEASEwebui" == "" ]] ) && [[ "$FORCEDOWNLOAD" -eq "" ]]
#then
  #indicates something wrong with the github call
#  echo ******** Warning - unable to check latest release!!  Please raise an issue https://github.com/kolonuk/get_iplayer-docker/issues/new
#fi

echo VERSION: $VERSION
echo RELEASE: $RELEASE

if [[ "$VERSION" == "" ]] || \
   [[ "$VERSIONwebui" == "" ]] || \
   [[ "$VERSION" != "$RELEASE" ]] || \
   [[ "$VERSIONwebui" != "$RELEASEwebui" ]] || \
   [[ "$FORCEDOWNLOAD" != "" ]]
then
  echo Getting latest version of youtube-dl...
  if [[ "$RELEASE" == "" ]]
  then
    # No release returned from github, download manually
    wget -q https://yt-dl.org/downloads/latest/youtube-dl -O /usr/local/bin/youtube-dl
    chmod a+rx /usr/local/bin/youtube-dl
  else
    # Download and unpack release
    wget -q https://github.com/rg3/youtube-dl/releases/download/$RELEASE/youtube-dl-$RELEASE.tar.gz -O /root/latest.tar.gz
    tar -xzf /root/latest.tar.gz --directory /root/
    cp -f /root/youtube-dl/youtube-dl /usr/local/bin/
    #rm -f /root/latest.tar.gz
    #rm -Rf youtube-dl
  fi

  echo Getting latest version of youtube-dl-webui...
  #if [[ "$RELEASE" == "" ]]
  #then
    # No release returned from github, download manually
  #  wget -q https://raw.githubusercontent.com/get-iplayer/get_iplayer/master/get_iplayer.cgi -O /root/get_iplayer.cgi
  #  chmod 755 /root/get_iplayer
  #else
    # Download and unpack release
  #  wget -q https://github.com/get-iplayer/get_iplayer/archive/v$RELEASE.tar.gz -O /root/latest.tar.gz
  #  cd /root
  #  tar -xzf /root/latest.tar.gz get_iplayer-$RELEASE --directory /root/ --strip-components=1
  #  rm /root/latest.tar.gz
  #fi

  #kill current get_iplayer gracefully (is pvr/cache refresh running?)
#  if [[ -f /root/.get_iplayer/pvr_lock ]] #|| [[ -f /root/.get_iplayer/??refreshcache_lock ]]
#  then
#    echo ****** Warning - updated scripts, but get_iplayer processes are running so unable to restart get_iplayer
#  else
    # This will kill the running perl processes, and the start script will just re-load it
#    if [[ "$1" != "start" ]]
#    then
#      echo Killing get_iplayer process...
#      killall -9 perl
#    fi
#  fi
fi
