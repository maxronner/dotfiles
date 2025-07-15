set -a
source ~/.config/environment.d/gtk.conf
set +a

systemctl --user import-environment GTK_THEME
systemctl --user restart gpg-agent

