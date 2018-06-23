#salt -L salt-master azurearm_network.load_balancer_create_or_update test-lb salt-master location=northeurope subscription_id=a8e8d31d-3a2d-4af9-bfac-167bb8d7e2b1 tenant=66073837-365e-43a1-a820-a5dd1ad558cb client_id=94b7d274-8876-4429-aede-c42ec4b92987 secret=c5f13ca5-dc8c-480a-9df4-22979dc8f103
{% set profile = salt['pillar.get']('azurearm') %}

create public ip:
  azurearm_network.public_ip_address_present:
    - name: test-lb-public
    - resource_group: salt-master
    - public_ip_allocation_method: Static
    - public_ip_address_version: IPv4
    - location: northeurope
    - connection_auth: {{ profile }}

create lb:
  azurearm_network.load_balancer_present:
    - name: test-lb
    - resource_group: salt-master
    - location: northeurope
    - connection_auth: {{ profile }}
    - backend_address_pools:
      - name: backend-test-lb
    - sku: Basic
    - probes:
      - name: test-probe
        protocol: tcp
        port: 80
        interval_in_seconds: 5
        number_of_probes: 2
    - frontend_ip_configurations:
      - name: frontend1234
        public_ip_address: test-lb-public
