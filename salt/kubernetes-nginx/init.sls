create-namespace:
  kubernetes.namespace_present:
    - name: gce

create-config-map:
  kubernetes.configmap_present:
    - name: nginx-index
    - data: {'index': '<html><body><p><b><font size="5" color="red">Hello from : HOSTNAME</font></b></p></body></html>'}
    - namespace: gce

nginx-deployment:
  kubernetes.deployment_present:
    - name: nginx-deployment
    - source: salt://kubernetes-nginx/nginx.yaml
    - namespace: gce

nginx-deployment-service:
  kubernetes.service_present:
    - name: nginx-service
    - source: salt://kubernetes-nginx/nginx-service.yaml
    - namespace: gce
