export ZDOTDIR="/home/max/.config/zsh"

if [ -f "$ZDOTDIR/.ha-token" ] ; then
    export HA_TOKEN=$(cat $ZDOTDIR/.ha-token)
fi

