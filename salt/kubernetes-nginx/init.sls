create-namespace:
  kubernetes.namespace_present:
    - name: gce

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
