#!/bin/bash
salt-call state.apply kubernetes-node
if [ -e /etc/kubernetes/kubelet.conf ]
then
   rm -f /etc/cron.d/join
   exit 0;
fi
eval $(cat /root/join_command)
if [ $? -eq 0 ]
then
    rm -f /etc/cron.d/join
    echo "Joined cluster" >> /root/join.log
fi
