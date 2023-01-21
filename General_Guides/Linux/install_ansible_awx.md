Installing Ansible AWX
======================

## Installation Notes

The installation is different from the developers installation guide.

Instead of their preference of using minikube, this deployment will be using an actual kubernetes environment.

This is going to enable the service to be available upon reboot and other users on the network can access it.

Also this is an easier approach compared to using minikube.

Minikube is great for developers who need to spin something up and change some code and redeploy it, but for this deployment, we need it to be accessible for others in our environment and from external services like Slack and ServiceNow going to need to be able to hit that Ansible AWX.

## Deployment Environment

A virtual machine will be used within VMWare VCenter.

The operating system has to be a Linux distribution to run Kubernetes.

The deployment is based on a Ubuntu 22.04 LTS Linux install.

