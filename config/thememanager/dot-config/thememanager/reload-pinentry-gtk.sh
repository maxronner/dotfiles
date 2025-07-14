set -a
source ~/.config/environment.d/gtk.conf
set +a

systemctl --user import-environment GTK_THEME
systemctl --user daemon-reexec

while ! systemctl --user is-active gpg-agent.service > /dev/null 2>&1; do
  sleep 0.1
done

systemctl --user restart gpg-agent

