#seting up hstname and local dns entry
echo "54.176.122.32		master" >> /etc/hosts
echo "13.56.182.221		worker" >> /etc/hosts
hostnamectl set-hostname master

#disabling the firewalld and swap of machine
systemctl disable firewalld; systemctl stop firewalld
swapoff -a; sed -i '/swap/d' /etc/fstab

#setting the selinux permission to permissive
setenforce 0
sed -i --follow-symlinks 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
getenforce

#setting the ip table routing, used for kubernetes cni plugin for networking 
modprobe br_netfilter
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system

#installing the container runtime like containerd and docker 
yum install yum-utils -y
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

#we will use containerd as container runtime and we will not use docker
rm -f /etc/containerd/config.toml
systemctl start containerd
systemctl enable containerd

#installing kubelet,kubeadm,kubectl,crictl(this will be insatlled as dependency of kubeadm package) packages
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl start kubelet
systemctl enable kubelet

#start the cluster
kubeadm init
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
#installing the calico network
curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml -O
kubectl apply -f calico.yaml

#setting up crictl command to use containerd as conatiner runtime
crictl config --set runtime-endpoint=unix:///run/containerd/containerd.sock
crictl config --set image-endpoint=unix:///run/containerd/containerd.sock
crictl config --set timeout=10
crictl config --set debug=true
crictl config --set pull-image-on-create=false
crictl config --set disable-pull-on-run=false
cat /etc/crictl.yaml