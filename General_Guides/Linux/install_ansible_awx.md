Install Ansible AWX with Rancher k3s
=======================================

### System Requirements

The minimum system requirements are:
- 4 vCPU
- 8 GB RAM
- 60 GB HDD

### Installation Notes

The installation is different from the [developers installation guide](https://github.com/ansible/awx-operator).

Instead of their preference of using minikube, this deployment will be using an actual kubernetes environment.

This is going to enable the service to be available upon reboot and other users on the network can access it.

Also this is an easier approach compared to using minikube.

Minikube is great for developers who need to spin something up and change some code and redeploy it, but for this deployment, we need it to be accessible for others in our environment and from external services like Slack and ServiceNow going to need to be able to hit that Ansible AWX.

### Deployment Environment

A virtual machine will be used within VMWare VCenter.

The operating system has to be a Linux distribution to run Kubernetes.

The deployment is based on a Ubuntu 22.04 LTS Linux install.

## Installation

Kubernetes is a requirement for Ansible AWX.

We will be sticking with a single-host, non-clustered Kubernetes that is very lightweight and it does not have high availability or scale out functions.

### Update and Upgrade Packages

Be sure to update and upgrade your package manager before installation:

```bash
sudo apt -y update && sudo apt -y upgrade
```

### Kubernetes Installation with Script

```bash
curl -sfL https://get.k3s.io | sh -
```

Check the version of the Kubernetes install:

```bash
sudo kubectl version
```

### Add Privileges to kubectl

Make the /etc/rancher/k3s/k3s.yaml file accessible by the current user (`replace the username and group`):

```bash
sudo chown username:group /etc/rancher/k3s/k3s.yaml
```

Now the kubectl command can be used without elevated privileges.

### Kustomize Setup

Kustomize is a tool that will help us build a Kubernetes environment based on some parameters we pass.

Ansible AWX is going to need to have an AWX operator and it's going to handle the download, installation and provisioning of Ansible AWX inside of the Kubernetes environment. 

The following script detects your OS and downloads the appropriate kustomize binary to your current working directory.

```bash
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash 
```

Notes: 
  - This script doesn’t work on ARM architecture.

Move the binary to somewhere within the Linux install that is within the PATH, so that the operating system can find the executable for a command.

```bash
sudo mv kustomize /usr/local/bin
```

### Create kustomization.yaml 

Create the kustomization.yaml file for the Kustomize architect to read.

```bash
nano ~/kustomization.yaml
```

Add the following content to the file (`replace the <tag> with the latest release in https://github.com/ansible/awx-operator/releases`):

```bash
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  # Find the latest tag here: https://github.com/ansible/awx-operator/releases
  - github.com/ansible/awx-operator/config/default?ref=<tag>

# Set the image tags to match the git version from above
images:
  - name: quay.io/ansible/awx-operator
    newTag: <tag>

# Specify a custom namespace in which to install AWX
namespace: awx
```

### Kustomize Build

Kick off the kustomization binary to point to our local directory and then pipe the output to the Kubernetes binary called kubectl.

```bash
kustomize build . | kubectl apply -f -
```

### Check Build Progress

Check the workload and `ensure that the STATUS is Running` (wait about a minute for the container process to complete).

```bash
kubectl get pods -n awx
```

### Create awx.yaml

Create a file called awx.yaml

```bash
nano ~/awx.yaml
```

Add the following content to the file and tell AWX that we want the web service to be exposed on a specific port (`change the <nodeport_port> variable value`).

Notes:
- Select a non-default, available port
- Previous test deployments failed when `nodeport_port` was set to port 80!

```bash
---
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx
spec:
  service_type: nodeport
  # default nodeport_port is 30080
  nodeport_port: <nodeport_port>
```

### Add awx.yaml to the kustomization.yaml File

```bash
nano ~/kustomization.yaml
```

Add the awx.yaml entry to resources, like so:

```bash
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  # Find the latest tag here: https://github.com/ansible/awx-operator/releases
  - github.com/ansible/awx-operator/config/default?ref=<tag>
  - awx.yaml

# Set the image tags to match the git version from above
images:
  - name: quay.io/ansible/awx-operator
    newTag: <tag>

# Specify a custom namespace in which to install AWX
namespace: awx
```

### Run Kustomize Build Again

```bash
kustomize build . | kubectl apply -f -
```

The deployment can be watched using the kubectl logs command.

```bash
kubectl logs -f deployments/awx-operator-controller-manager -c awx-manager --namespace awx
```

After the deployment is done, check our workload and `ensure that the STATUS is Running` (wait about 10 minutes for the container process to complete):

```bash
kubectl get pods -n awx
```

### Retrieve the admin Password

A password was generated during the build process and we need to ask Kubernetes to reveal that password to us.

```bash
kubectl get secret awx-admin-password -o jsonpath="{.data.password}" --namespace awx | base64 --decode ; echo
```

### Login to the AWX Web UI

Open a web browser and navigate to the `IP:PORT` AWX web interface.

The username to login is: admin
The password to login with admin is the string that was generated by `kubectl get secret` command.

## Uninstall

To uninstall an AWX deployment instance, you basically need to remove the AWX kind related to that instance.

```bash
kubectl get nodes -n awx
```

Check the pods running under the AWX deployment.

```bash
kubectl get pods -n awx -o wide
```

Delete an AWX instance named ansible:

```bash
kubectl drain ansible --ignore-daemonsets --delete-emptydir-data --force
```

## References
  - https://github.com/ansible/awx-operator#purpose
  - https://www.youtube.com/watch?v=Nvjo2A2cBxI&list=WL&index=7&t=1683s&ab_channel=CalvinRemsburg
