
#!/bin/bash
cd terraform
terraform init
terraform apply -auto-approve
cd ..
ansible-playbook -i "EC2_IP," -u "ubuntu" --private-key ~/.ssh/key.pem ansible/playbooks/setup.yml
