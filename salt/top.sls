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
