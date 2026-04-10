bootstrap env='':
  @bash install/phases/bootstrap.sh {{env}}

preflight:
  @bash install/phases/preflight.sh

packages env='':
  @bash install/phases/packages.sh {{env}}

activate env='':
  @bash install/phases/activate.sh {{env}}

home env='':
  @bash install/phases/apply-home.sh {{env}}
  @bash install/phases/apply-hooks.sh

unstow env='':
  @bash install/phases/unstow.sh {{env}}

lint:
  @missing=0; \
  for dir in "{{justfile_directory()}}"/apps/*/ "{{justfile_directory()}}"/system/*/ "{{justfile_directory()}}"/optional/*/ "{{justfile_directory()}}"/devices/*/; do \
    if [ ! -f "$dir/pkg.txt" ]; then \
      echo "MISSING pkg.txt: $dir"; \
      missing=1; \
    fi; \
  done; \
  [ $missing -eq 0 ] && echo "All packages have pkg.txt" || exit 1
