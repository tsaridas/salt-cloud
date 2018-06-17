get join command:
  file.managed:
    - name: /root/join_command
    - source: salt://minionfs/{{ grains['join'] }}/root/join_command

create join script:
  file.managed:
    - name: /root/join.sh
    - source: salt://kubernetes-node/join.sh
    - mode: 744

create cronjob file:
  file.managed:
    - name: /etc/cron.d/join
    - source: salt://kubernetes-node/join.cron
    - onchanges:
      - file: get join command
