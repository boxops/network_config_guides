# Silently generate SSH keys

# Reference
# https://stackoverflow.com/questions/43235179/how-to-execute-ssh-keygen-without-prompt

echo SSH key filename:

read filename

cd ~/.ssh

ssh-keygen -t rsa -b 4096 -N '' -f ~/.ssh/$filename <<<y >/dev/null 2>&1

eval $(ssh-agent -s)

ssh-add
