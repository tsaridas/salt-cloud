install selinux module:
  pkg.installed:
    - pkgs:
      - libselinux-python
      - policycoreutils-python
      - selinux-policy-targeted

disable firewalld:
  service.dead:
    - name: firewalld
    - enable: False

disable swap:
  cmd.run:
    - name: swapoff -a
    - unless: if [[ $(swapon | wc -l) = 2 ]]; then exit 1;fi

install docker node:
  pkg.installed:
    - name: docker

docker running node:
  service.running:
    - name: docker
    - enable: True

set permissive:
  selinux.mode:
    - name: permissive
