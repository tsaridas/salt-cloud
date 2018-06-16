highstate_run:
  local.state.apply:
    - tgt: {{ data['id'] }}

copy_pillar:
  local.state.apply:
    - tgt: salt-master
[root@salt-master salt]# cat top.sls
base:
  'kubernetes-master:True':
    - match: grain
    - docker
    - kubernetes
    - kubernetes-master
  'kubernetes-node:True':
    - match: grain
    - docker
    - kubernetes
    - kubernetes-node
  'salt-master':
    - salt-master
