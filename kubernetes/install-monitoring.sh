helm upgrade prom prometheus --install --wait -f prometheus/custom_values.yml
PROM_EXT_IP=$(kubectl get svc prom-prometheus-server | awk 'NR>1{print $4}')

function create_grafana_datasource(){
cat <<EOF | curl -i -X POST -d "@-" -H "Accept: application/json" -H "Content-Type: application/json" "http://admin:secret@$GITLAB_IP:3000/api/datasources"
{
    "name": "prom",
    "type": "prometheus",
    "typeLogoUrl": "public/app/plugins/datasource/prometheus/img/prometheus_logo.svg",
    "access": "proxy",
    "url": "http://$PROM_EXT_IP",
    "password": "",
    "user": "",
    "database": "",
    "basicAuth": false,
    "isDefault": true,
    "jsonData": {
        "keepCookies": []
    },
    "readOnly": false
}
EOF
}

function create_grafana_dashboards(){
curl -i -X POST -H "Accept: application/json" -H "Content-Type: application/json" -d "@grafana-dashboard/Crawler.json" "http://admin:secret@$GITLAB_IP:3000/api/dashboards/db"
curl -i -X POST -H "Accept: application/json" -H "Content-Type: application/json" -d "@grafana-dashboard/Kubernetes_cluster.json" "http://admin:secret@$GITLAB_IP:3000/api/dashboards/db"
curl -i -X POST -H "Accept: application/json" -H "Content-Type: application/json" -d "@grafana-dashboard/Kubernetes_Deployment_metrics.json" "http://admin:secret@$GITLAB_IP:3000/api/dashboards/db"
curl -i -X POST -H "Accept: application/json" -H "Content-Type: application/json" -d "@grafana-dashboard/UI.json" "http://admin:secret@$GITLAB_IP:3000/api/dashboards/db"
}


create_grafana_datasource
create_grafana_dashboards

echo ""
echo "Web site Gitlab-ci: http://$GITLAB_IP"
echo "Web site Grafana http://$GITLAB_IP:3000"
echo "Web site Prometheuse http://$PROM_EXT_IP"