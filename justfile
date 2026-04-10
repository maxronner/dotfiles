bootstrap env='':
  @bash install/lib/preflight.sh
  just system {{env}}
  just user {{env}}

system env='':
  @bash install/system/packages.sh {{env}}
  @bash install/system/config.sh {{env}}
  @bash install/system/device.sh {{env}}

user env='':
  @bash install/lib/preflight.sh
  @bash install/user/dotfiles.sh {{env}}
  @bash install/user/finalize.sh
  @bash install/user/services.sh

extra name='':
  #!/usr/bin/env bash
  if [ -z "{{name}}" ]; then
    echo "Available extras:"
    for f in install/extras/*.sh; do
      basename "$f" .sh
    done
    exit 0
  fi
  if [ ! -f "install/extras/{{name}}.sh" ]; then
    echo "Unknown extra: {{name}}"
    echo ""
    echo "Available extras:"
    for f in install/extras/*.sh; do
      basename "$f" .sh
    done
    exit 1
  fi
  bash "install/extras/{{name}}.sh"

unlink env='':
  @bash install/lib/unlink.sh {{env}}

lint:
  @missing=0; \
  for dir in "{{justfile_directory()}}"/apps/*/ "{{justfile_directory()}}"/system/*/ "{{justfile_directory()}}"/optional/*/ "{{justfile_directory()}}"/devices/*/; do \
    if [ ! -f "$dir/pkg.txt" ]; then \
      echo "MISSING pkg.txt: $dir"; \
      missing=1; \
    fi; \
  done; \
  [ $missing -eq 0 ] && echo "All packages have pkg.txt" || exit 1
