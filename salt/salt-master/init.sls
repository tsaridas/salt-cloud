copy pillar:
  file.managed:
    - source: salt://minionfs/kubernetes-master/root/join_command
    - name: /srv/pillar/join_command.sls
