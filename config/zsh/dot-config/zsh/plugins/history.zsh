HISTFILE="$XDG_DATA_HOME/zsh/history"
HIST_STAMPS="yyyy-mm-dd"
HISTSIZE=100000
SAVEHIST=100000

# History behavior
setopt HIST_IGNORE_DUPS      # don't record immediately duplicated commands
setopt HIST_IGNORE_ALL_DUPS  # remove older duplicate entries
setopt HIST_FIND_NO_DUPS     # don't show duplicates during search
setopt HIST_REDUCE_BLANKS    # remove extra spaces
setopt HIST_VERIFY           # edit command before executing from history
setopt SHARE_HISTORY         # share history across all sessions
setopt INC_APPEND_HISTORY    # write history incrementally
setopt EXTENDED_HISTORY      # add timestamp + duration
