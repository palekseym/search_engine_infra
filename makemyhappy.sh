cd infrastructure && terraform init && terraform apply --auto-approve
GITLAB_IP=$(terraform output | awk '/ip =/ {print $3}')
cd ../
sed -i "s/[0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+/$GITLAB_IP/" kubernetes/gitlab-runner/values.yaml
sed -i "s/[0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+/$GITLAB_IP/" ansible/inventory
sed -i "s/[0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+/$GITLAB_IP/" kubernetes/helm/service-gitlab-ip.yml
cd ansible
ansible-playbook playbooks/install-gitlab.yml
ansible-playbook playbooks/install-grafana.yml
cd ..
for i in {1..120}; do curl -sf "http://$GITLAB_IP"; if [ $? -eq 0 ]; then echo "Yes";break; fi; echo "Wait start GITLAB on $GITLAB_IP";sleep 1; done
cd kubernetes
./install-helm-to-cluster.sh
echo ""
./install-gitlab_runner.sh
echo ""
source ./install-monitoring.sh

