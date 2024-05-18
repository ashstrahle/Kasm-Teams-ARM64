FROM kasmweb/core-ubuntu-jammy:1.15.0
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########

ENV VERSION 1.4.37
RUN wget -O teams.deb https://github.com/IsmaelMartinez/teams-for-linux/releases/download/v${VERSION}/teams-for-linux_${VERSION}_arm64.deb

RUN apt-get update
RUN apt-get install -y xdg-utils
RUN dpkg -i ./teams.deb
RUN rm ./teams.deb

# Update the desktop environment to be optimized for a single application
RUN cp $HOME/.config/xfce4/xfconf/single-application-xfce-perchannel-xml/* $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/
RUN rm -f /usr/share/backgrounds/bg_default.png
RUN apt-get remove -y xfce4-panel

RUN echo $'#!/usr/bin/env bash \n\
set -ex \n\
START_COMMAND="/usr/bin/teams-for-linux" \n\
PGREP="teams-for-linux" \n\
DEFAULT_ARGS="--no-sandbox" \n\
export MAXIMIZE="true" \n\
export MAXIMIZE_NAME="Teams" \n\
MAXIMIZE_SCRIPT=$STARTUPDIR/maximize_window.sh \n\
ARGS=${APP_ARGS:-$DEFAULT_ARGS} \n\
\n\
options=$(getopt -o gau: -l go,assign,url: -n "$0" -- "$@") || exit \n\
eval set -- "$options" \n\
\n\
while [[ $1 != -- ]]; do \n\
    case $1 in \n\
        -g|--go) GO="true"; shift 1;; \n\
        -a|--assign) ASSIGN="true"; shift 1;; \n\
        -u|--url) OPT_URL=$2; shift 2;; \n\
        *) echo "bad option: $1" >&2; exit 1;; \n\
    esac \n\
done \n\
shift \n\
\n\
# Process non-option arguments. \n\
for arg; do \n\
    echo "arg! $arg" \n\
done \n\
\n\
FORCE=$2 \n\
\n\
kasm_exec() { \n\
    if [ -n "$OPT_URL" ] ; then \n\
        URL=$OPT_URL \n\
    elif [ -n "$1" ] ; then \n\
        URL=$1 \n\
    fi  \n\
    \n\
    # Since we are execing into a container that already has the browser running from startup,  \n\
    #  when we dont have a URL to open we want to do nothing. Otherwise a second browser instance would open.  \n\
    if [ -n "$URL" ] ; then \n\
        /usr/bin/filter_ready \n\
        /usr/bin/desktop_ready \n\
        bash ${MAXIMIZE_SCRIPT} & \n\
        $START_COMMAND $ARGS $OPT_URL \n\
    else \n\
        echo "No URL specified for exec command. Doing nothing." \n\
    fi \n\
} \n\
\n\
kasm_startup() { \n\
    if [ -n "$KASM_URL" ] ; then \n\
        URL=$KASM_URL \n\
    elif [ -z "$URL" ] ; then \n\
        URL=$LAUNCH_URL \n\
    fi \n\
    \n\
    if [ -z "$DISABLE_CUSTOM_STARTUP" ] ||  [ -n "$FORCE" ]; then \n\
    \n\
        echo "Entering process startup loop" \n\
        set +x \n\
        while true \n\
        do \n\
            if ! pgrep -x $PGREP > /dev/null \n\
            then \n\
                /usr/bin/filter_ready \n\
                /usr/bin/desktop_ready \n\
                set +e \n\
                bash ${MAXIMIZE_SCRIPT} & \n\
                $START_COMMAND $ARGS $URL \n\
                set -e \n\
            fi \n\
            sleep 1 \n\
        done \n\
        set -x \n\
        \n\
    fi \n\
    \n\
}  \n\
\n\
if [ -n "$GO" ] || [ -n "$ASSIGN" ] ; then \n\
    kasm_exec \n\
else \n\
    kasm_startup \n\
fi' > $STARTUPDIR/custom_startup.sh \
  && chmod +x $STARTUPDIR/custom_startup.sh

######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000