FROM	ubuntu:16.04

ARG     GRAFANA_VERSION=latest
ARG     GRAFANA_DEST=/src/grafana
ARG     INFLUXDB_VERSION=0.13.0

# Prevent some error messages
ARG     DEBIAN_FRONTEND=noninteractive

RUN		apt-get -y update && \
            apt-get -y upgrade

# ---------------- #
#   Installation   #
# ---------------- #

# Install all prerequisites
RUN 	apt-get -y install wget curl nginx-light supervisor

# Install Grafana to /src/grafana
RUN		mkdir -p ${GRAFANA_DEST} && \
            cd ${GRAFANA_DEST} && \
			wget https://grafanarel.s3.amazonaws.com/builds/grafana-${GRAFANA_VERSION}.linux-x64.tar.gz -O grafana.tar.gz && \
			tar xzf grafana.tar.gz --strip-components=1 && \
			rm grafana.tar.gz

# Install Grafana plugins
#RUN     ${GRAFANA_DEST}/bin/grafana-cli --pluginsDir "${GRAFANA_DEST}/public/app/plugins" plugins install alexanderzobnin-zabbix-app

# Install InfluxDB
RUN		wget https://dl.influxdata.com/influxdb/releases/influxdb_${INFLUXDB_VERSION}_amd64.deb && \
			dpkg -i influxdb_${INFLUXDB_VERSION}_amd64.deb && \
			rm influxdb_${INFLUXDB_VERSION}_amd64.deb

# ----------------- #
#   Configuration   #
# ----------------- #

# Configure InfluxDB
ADD		influxdb/config.toml /etc/influxdb/config.toml
ADD		influxdb/run.sh /usr/local/bin/run_influxdb

# These two databases have to be created. These variables are used by set_influxdb.sh
ENV		PRE_CREATE_DB metrics
ENV		INFLUXDB_URL http://localhost:8086
ENV		INFLUXDB_ADMIN_USER root
ENV		INFLUXDB_ADMIN_PW root

ADD		./configure.sh /configure.sh
ADD		./set_influxdb.sh /set_influxdb.sh
RUN 	/configure.sh

# Configure nginx and supervisord
ADD		./nginx/nginx.conf /etc/nginx/nginx.conf
ADD		./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# ----------- #
#   Cleanup   #
# ----------- #

RUN		apt-get autoremove -y wget curl && \
			apt-get -y clean && \
			rm -rf /var/lib/apt/lists/* && \
			rm /*.sh

# ---------------- #
#   Expose Ports   #
# ---------------- #

# Grafana
EXPOSE	80

# InfluxDB Admin server
EXPOSE	8083

# InfluxDB HTTP API
EXPOSE	8086

# -------- #
#   Run!   #
# -------- #

CMD		["/usr/bin/supervisord"]
