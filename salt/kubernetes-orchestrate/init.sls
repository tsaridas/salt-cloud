{% set master = salt['pillar.get']('kubernetes-master', 'kubernetes-master') %}
{% set nodes = salt['pillar.get']("kubernetes-nodes", ["kubernetes-node"]) %}
create_master:
  salt.runner:
    - name: cloud.profile
    - prof: rh7
    - provider: gce-config
    - parallel: True
    - instances:
      - {{ master }}
    - opts:
        grains:
          kubernetes-master: True
        minion:
          master: 10.166.0.2

{% for node in nodes %}
create_node_{{ node }}:
  salt.runner:
    - name: cloud.profile
    - prof: rh7
    - parallel: True
    - provider: gce-config
    - instances:
      - {{ node }}
    - opts:
        grains:
          kubernetes-node: True
          join: kubernetes-master
        minion:
          master: 10.166.0.2
{% endfor %}

create_heathcheck:
  salt.runner:
    - name: cloud.action
    - func: create_hc
    - provider: gce
    - aname: hc
    - path: /
    - port: 30443
    - timeout: 3
    - interval: 5
    - unhealthy_threshold: 2
    - healthy_threshold: 1

create_lb:
  salt.runner:
    - name: cloud.action
    - func: create_lb
    - provider: gce
    - aname: nginx-lb
    - region: europe-north1
    - ports: 80
    - healthchecks: hc
    - members: {% for node in nodes %}{{ node }}{% if not loop.last %},{% endif %}{% endfor %}
    - require:
      - salt: create_master

sleep:
  salt.function:
    - name: test.sleep
    - tgt: salt-master
    - arg:
      - 170
    - require:
      - salt: create_master

deploy_nginx:
  salt.state:
    - sls: kubernetes-nginx
    - tgt_type: list
    - tgt: {{ master }}
    - require:
      - salt: sleep

deploy_haproxy:
  salt.state:
    - sls: kubernetes-ingress
    - tgt_type: list
    - tgt: {{ master }}
    - require:
      - salt: sleep

{% for node in nodes %}
target_nodes_{{ node }}:
  salt.function:
    - name: cmd.run
    - tgt_type: list
    - tgt: {{ master }}
    - arg:
      - kubectl label node {{ node }} role=ingress-controller --overwrite
    - require:
      - salt: sleep
{% endfor %}
