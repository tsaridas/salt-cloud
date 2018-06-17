setup repo node:
  pkgrepo.managed:
    - name: kubernetes
    - humanname: Kubernetes
    - baseurl: https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
    - comments:
        - 'https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64'
    - enabled: 1
    - gpgcheck: 1
    - gpgkey: https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg

install kubeadm node:
  pkg.installed:
    - name: kubeadm

net.bridge.bridge-nf-call-ip6tables:
  sysctl.present:
    - value: 1

net.bridge.bridge-nf-call-iptables:
  sysctl.present:
    - value: 1

enable kubelet:
  service.enabled:
    - name: kubelet
