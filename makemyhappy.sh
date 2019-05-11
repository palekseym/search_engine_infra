cd infrastructure && terraform init && terraform apply --auto-approve
GITLAB_IP=$(terraform output | awk '/ip =/ {print $3}')
cd ../
sed -i "s/[0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+/$GITLAB_IP/" kubernetes/gitlab-runner/values.yaml
sed -i "s/[0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+/$GITLAB_IP/" ansible/inventory
cd ansible
ansible-playbook playbooks/install-gitlab.yml
ansible-playbook playbooks/install-grafana.yml
cd ..
for i in {1..120}; do curl -sf "http://$GITLAB_IP"; if [ $? -eq 0 ]; then echo "Yes";break; fi; echo "Wait start GITLAB on $GITLAB_IP";sleep 1; done
cd kubernetes
./install-helm-to-cluster.sh
./install-gitlab_runner.sh
./install-monitoring.sh
