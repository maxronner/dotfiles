if [ -f "$ZDOTDIR/.ha-token" ] ; then
    export HA_TOKEN=$(cat $ZDOTDIR/.ha-token)
fi

if [ -f "$ZDOTDIR/.gemini-api-key" ] ; then
    export GEMINI_API_KEY=$(cat $ZDOTDIR/.gemini-api-key)
fi

if [ -f "$ZDOTDIR/.openai-api-key" ] ; then
    export OPENAI_API_KEY=$(cat $ZDOTDIR/.openai-api-key)
fi

if [ -f "$XDG_CONFIG_HOME/environment/common-profile.sh" ] ; then
    source "$XDG_CONFIG_HOME/environment/common-profile.sh"
fi
