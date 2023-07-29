#set hostname and local dns
hostnamectl set-hostname minikube
echo "3.101.88.31	master" >> /etc/hosts

#installing the container runtime like containerd and docker 
yum install yum-utils -y
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

#start docker as we will user docker as background container runtime engine for minikube
systemctl start docker
systemctl enable docker

#install kubectl package
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

yum install -y kubectl --disableexcludes=kubernetes

#install Minikube
#get the latest curl link from : https://minikube.sigs.k8s.io/docs/start/
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube

#start Minikube
minikube start --force
