#!/bin/sh

## Change these configuration variables. They should probably match server.properties
## Leave them blank if you think I'm a good guesser.
SERVER_PROPERTIES=
SERVER_PROPERTIES=${SERVER_PROPERTIES:-/srv/tekkit/server.properties}

QUERY_PORT=
QUERY_PORT=${QUERY_PORT:-(sed -n 's/^query.port=([0-9]*)$/\1/p' ${SERVER_PROPERTIES})}

PUBLIC_IP=
PUBLIC_IP=${PUBLIC_IP:-`curl ifconfig.me`}

LOCAL_PORT=
LOCAL_PORT=${LOCAL_PORT:-(sed -n 's/^server-port=([0-9]*)$/\1/p' ${SERVER_PROPERTIES})}

LOCAL_IP=
LOCAL_IP=${LOCAL_IP:-(sed -n 's/^server-ip=([0-9]*)$/\1/p' ${SERVER_PROPERTIES})}

MINECRAFT_JAR=
MINECRAFT_JAR=${MINECRAFT_PATH:-/srv/tekkit/Tekkit.jar}

MINECRAFT_LOG=
MINECRAFT_LOG=${MINECRAFT_PATH:-/srv/tekkit/server.log}

## NB: This default may not be sensible
JAVAOPTS=
JAVAOPTS=${JAVAOPTS:--Xmx2G -Xms1G -server -XX:+UseG1GC -XX:MaxGCPauseMillis=50 \
  -XX:ParallelGCThreads=2 -XX:+DisableExplicitGC -XX:+AggressiveOpts -d64}

SESSION=
SESSION=${SESSION:-Minecraft}

MESSAGE=
MESSAGE=${MESSAGE:-Wat}

WAIT_TIME=
WAIT_TIME=${WAIT_TIME:-600}

SERVER_USER=
SERVER_USER=${SERVER_USER:-tekkit}

LAUNCH=
LAUNCH=${LAUNCH:-/etc/tekkit-on-demand/launch.sh}

START_LOCKFILE=
START_LOCKFILE=${START_LOCKFILE:-/tmp/startingtekkit}

IDLE_LOCKFILE=
IDLE_LOCKFILE=${START_LOCKFILE:-/tmp/idleingtekkit}

## You may not need to change this.

## Define this function to start the minecraft server. This should start
## the server, and do any pre or post processing steps you might need.

## This command will be run in a screen session to communicate with the
## server
start() {
  /usr/bin/java $JAVAOPTS -jar $JAVAOPTS nogui 2>&1 | grep -v -e "^INFO" -e "Can't keep up"
}


## You may not need to change this.

## Define this function to start the minecraft server. This should start
## the server, and do any pre or post processing steps you might need.

## This command will be run by crontab to stop the server.
stop() {
  screen -S $SESSION -p 0 -X stuff 'stop15'
}

## Define this function to return true if and only if the server has no
## players online. The server will shut down
idle(){
  screen -S $SESSION -p 0 -X stuff 'who15'
  PLAYERS=echo $(tail -n 1 $MINECRAFT_LOG | cut -f 6- -d ' ' | wc -m)
  [ "0" = "$PLAYERS" ]
}
