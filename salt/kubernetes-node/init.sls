sync all:
  module.run:
    - name: saltutil.sync_all

run join command node:
  cmd.run:
    - name: sleep 60;{{ pillar['join'] }}
    - cwd: /
    - creates: /etc/kubernetes/kubelet.conf
