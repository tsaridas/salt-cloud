copy_ingress:
  file.managed:
    - name: /root/kubernetes-ingress.yaml
    - source: salt://kubernetes-ingress/haproxy.yaml

apply_ingress:
  cmd.run:
    - name: kubectl create -f /root/kubernetes-ingress.yaml
    - unless: if [[ $(kubectl get svc --namespace=ingress-controller 2>&1) == *"No resources found"* ]]; then exit 1; fi
