# Guidance to run the script

## Update the IP address
- In the local DNS entry update the IP address of master and worker node
```sh
#seting up hostname and local dns entry
echo "54.176.122.32		master" >> /etc/hosts
echo "13.56.182.221		worker" >> /etc/hosts
```
## Run Script
- Run Master_Kubeadm.sh script in master machine
- Run Worker_Kubeadm script in worker machine 

## Post script run 
- Go to master node and scroll up to find woker node join command (sample as below)
```sh
kubeadm join 192.168.234.128:6443 --token 7qoocz.mslo8lrdd5xgo0az  --discovery-token-ca-cert-hash sha256:1c0aefea296af9ea3c81878a0aa69e34a54fdd219230b135b08f76ca74c4ad54
```
- If you are not able to find the worker node join command the follow below command to build the command(run the below commands in master node)
```sh
#get bootstarp token 
kubeadm token list -n kube-system
#Get CA certifiate in SHA256 encoded format
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
#Get Kube-apiserver ip and port
kubectl cluster-info
#Combine the api-server ip,tiken ID , CA certificate and build the Join command 
kubeadm join <control-plane-host>:<control-plane-port> --token <token> --discovery-token-ca-cert-hash sha256:<hash> 
```
- Copy the above worker node join command and run it in worker node 

