install all requirements:
  pkg.installed:
    - pkgs:
      - git
      - salt-master
      - salt-minion
      - salt-cloud

/etc/salt/master.d/reactor.conf:
  file.managed:
    - source: salt://salt-master/reactor.conf

/etc/salt/master.d/minionfs.conf:
  file.managed:
    - source: salt://salt-master/minionfs.conf

/usr/lib/python2.7/site-packages/salt/cloud/clouds/gce.py:
  file.managed:
    - source: salt://salt-master/gce.py

start and enable salt-master:
  service.running:
    - name: salt-master
    - enable: True
    - watch:
      - file: /etc/salt/master.d/reactor.conf
      - file: /etc/salt/master.d/minionfs.conf

start and enable salt-minion:
  service.running:
    - name: salt-minion
    - enable: True

disable firewalld:
  service.dead:
    - name: firewalld
    - enable: False

