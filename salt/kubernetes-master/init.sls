Install kubernetes:
  cmd.run:
    - name: kubeadm init
    - cwd: /
    - creates: /etc/kubernetes/admin.conf

copy config:
  file.copy:
    - name: /root/.kube/config
    - source: /etc/kubernetes/admin.conf
    - makedirs: True
    - user: root
    - group: root
    - require:
      - cmd: Install kubernetes

get join command:
  cmd.run:
    - name: 'sleep 30;echo join: \"$(kubeadm token create --print-join-command)\" > /root/join_command'
    - creates: /root/join_command
    - require:
      - cmd: Install kubernetes

push config:
  module.run:
    - name: cp.push
    - path: '/root/join_command'
    - require:
      - cmd: get join command

run weave:
  cmd.run:
    - name: curl https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n') -o /root/weave.yaml; kubectl apply -f /root/weave.yaml
    - creates: /root/weave.yaml
    - require:
      - cmd: Install kubernetes
      - cmd: get join command
      - module: push config
