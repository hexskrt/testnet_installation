<p align="center">
  <img height="150" height="auto" src="https://www.bogotobogo.com/DevOps/Docker/images/Docker-Prometheus-Grafana/grafana-prometheus.png">
</p>

Prometheus and Grafana are two of the most popular open-source tools used for monitoring and visualization. is an open-source metrics-based monitoring and alerting solution, and the de facto standard when it comes to monitoring Kubernetes, while Grafana is an open-source data visualization tool that helps users understand complex data through some great visualization. In this article, we provide a tutorial for using Grafana and Prometheus. We explain how to best use these tools together.

## Prerequisites

Before we jump to installation, there are a few prerequisites that need to be in place.

- Ubuntu 20.04+ / 1 VCPU / 2 GB RAM / 20 GB SSD
- Docker and Docker Compose 

### Step 1 - Directory for Monitoring
Create a new directory for Grafana and Prometheus configuration.
```
mkdir Monitoring
```

### Step 2 - Docker Compose 
Create a new files named of docker-compose.yml inside "Monitoring" directory add input config on below:
```
version: '3'

services:
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
    - GF_AUTH_ANONYMOUS_ENABLED=true  
```
### Step 3 - Prometheus File
We are still in the "Monitoring" folder. Create a new files named of prometheus.yml add input config on below:
```
global:
  scrape_interval:     15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'node_exporter'
    scrape_interval: 5s
    static_configs:
      - targets: ['node-exporter:9100']
  - job_name: "nolus-testnet"
    metrics_path: '/metrics'
    static_configs:
      - targets: ["127.0.0.1:04660"] # Adjust with your "NOLUS PORT"! or You can use direct your IP Server
```
After you successfully create prometheus.yml then restart you prometheus, and make sure you have enable your prometheus setting from `false` to `true` on $HOME/.nolus/config/config.toml
### Step 4 - Start Container
Use the following command to start the containers:
```
docker-compose up -d
```
### Step 5 - Verify Container
Use the following command to verify that the containers are running:
```
docker-compose ps / docker ps -a
```
You should see output similar to the following like this:
```
       Name                      Command               State                   Ports                 
---------------------------------------------------------------------------------------------------
monitoring_grafana_1   /run.sh                          Up      0.0.0.0:3000->3000/tcp              
monitoring_prometheus_1   /bin/prometheus --config ...   Up      0.0.0.0:9090->9090/tcp 
```
That's mean you have create service for Grafana & Prometheus! Ok we go to next step
### Step 6 - Access Grafana Web Interface
Open a web browser and navigate to http://IPSERVER:3000 or your custom domain, in this case im using https://monitoring.hexskrt.net to manage my monitoring dashboard. You should see the Grafana login page. Use the default username and password (admin/admin) to log in dashboard.

<p align="center">
  <img height="300" height="auto" src="https://i.imgur.com/eHhBwbM.png">
</p>
