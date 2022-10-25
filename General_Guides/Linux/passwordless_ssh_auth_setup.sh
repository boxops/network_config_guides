# Silently generate SSH keys and append it to a remote host

echo New SSH key filename:

read SSHFILENAME

echo Remote host IP

read REMOTEIP

echo Remote host username

read REMOTEUSERNAME

cd ~/.ssh

ssh-keygen -t rsa -b 4096 -N '' -f ~/.ssh/$SSHFILENAME <<<y >/dev/null 2>&1

eval $(ssh-agent -s)

ssh-add ~/.ssh/$SSHFILENAME

ssh-copy-id -i ~/.ssh/$SSHFILENAME.pub $REMOTEUSERNAME@$REMOTEIP

# If by some reason the ssh-copy-id utility is not available on your local computer you can use the following command to copy the public key:
# cat ~/.ssh/id_rsa.pub | ssh remote_username@server_ip_address "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
