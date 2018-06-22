{% set master = salt['pillar.get']('kubernetes-master', 'kubernetes-master') %}
{% set nodes = salt['pillar.get']("kubernetes-nodes", ["kubernetes-node"]) %}
create_master:
  salt.runner:
    - name: cloud.profile
    - prof: azure-rh7-master
    - provider: azure
    - parallel: True
    - instances:
      - {{ master }}
    - opts:
        grains:
          kubernetes-master: True
        minion:
          master: 172.16.0.4

{% for node in nodes %}
create_node_{{ node }}:
  salt.runner:
    - name: cloud.profile
    - prof: azure-rh7-node
    - parallel: True
    - provider: azure
    - instances:
      - {{ node }}
    - opts:
        grains:
          kubernetes-node: True
          join: kubernetes-master
        minion:
          master: 172.16.0.4
{% endfor %}

check_kubernetes_master:
  salt.function:
    - name: cmd.run
    - tgt: {{ master }}
    - arg:
      - while true; do if [[ $(kubectl get nodes 2>&1 | grep {{ master }}) == *"{{ master }}   Ready"* ]]; then exit 0; else sleep 5;fi; done
    - timeout: 400
    - require:
      - salt: create_master
      
{% for node in nodes %}
check_kubernetes_{{ node }}:
  salt.function:
    - name: cmd.run
    - tgt: {{ master }}
    - arg:
      - while true; do if [[ $(kubectl get nodes 2>&1 | grep {{ node }}) == *"{{ node }}   Ready"* ]]; then exit 0; else sleep 5;fi; done
    - timeout: 400
    - require:
      - salt: create_master
{% endfor %}

sleep:
  salt.function:
    - name: test.sleep
    - tgt: salt-master
    - arg:
      - 5
    - timeout: 5
    - require:
      - salt: create_master
      - salt: check_kubernetes_master

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

wait_for_website:
  salt.function:
    - name: cmd.run
    - tgt: salt-master
    - arg:
      - while true; do curl www.example.com > /dev/null 2>&1 ; req=$?; if [[ $req -eq 0 ]]; then break; else sleep 2; fi; done
    - timeout: 5
    - require:
      - salt: deploy_haproxy
