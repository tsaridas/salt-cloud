Install kubernetes:
  cmd.run:
    - name: kubeadm init
    - cwd: /
    - creates: /etc/kubernetes/admin.conf

get join command:
  cmd.run:
    - name: 'echo $(kubeadm token create --print-join-command) > /root/join_command'
    - creates: /root/join_command
    - require:
      - cmd: Install kubernetes

push config:
  module.run:
    - name: cp.push
    - path: '/root/join_command'
    - require:
      - cmd: get join command

copy config:
  file.copy:
    - name: /root/.kube/config
    - source: /etc/kubernetes/admin.conf
    - makedirs: True
    - user: root
    - group: root
    - require:
      - cmd: Install kubernetes

run weave:
  cmd.run:
    - name: curl https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n') -o /root/weave.yaml; kubectl apply -f /root/weave.yaml
    - creates: /root/weave.yaml
    - require:
      - cmd: Install kubernetes
      - cmd: get join command
      - module: push config

install pip:
  pkg.installed:
    - name: python2-pip

install kubernetes module:
  pip.installed:
    - name: kubernetes == 2.0.0

sync modules:
  module.run:
    - name: saltutil.sync_all
