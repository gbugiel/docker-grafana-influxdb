docker-grafana-influxdb
=======================

This image contains a default configuration of InfluxDB and Grafana.
It explicitly doesn't bundle an example dashboard.

* [Grafana](http://grafana.org/)
* [InfluxDB](https://influxdata.com/time-series-platform/influxdb/)

### Using the Dashboard ###

Once your container is running all you need to do is open your browser pointing to the host / port you just published and play with the dashboard at your wish.
We hope that you have a lot of fun with this image and that it serves it's purpose of making your life easier.

### Building the image yourself ###

The Dockerfile and supporting configuration files are available in this GitHub repository.
This comes specially handy if you want to change InfluxDB settings, or simply if you want to know how the image was built.
The repo also has `build`, `start`, `attach` and `stop` scripts to make your workflow more pleasant.

### Configuring the settings  ###

The container exposes the following ports by default:

- `80`: Grafana web interface
- `8083`: InfluxDB Admin web interface
- `8086`: InfluxDB HTTP API

To start a container with your custom config: see `start` script.

To change ports, consider the following:

- `80`: edit `Dockerfile, ngingx/nginx.conf and start script`.
- `8083`: edit: `Dockerfile, influxDB/config.toml and start script`.
- `8086`: edit: `Dockerfile, influxDB/config.toml, set_influxdb.sh and start script`.

### Getting IP of your docker-machine ###
```bash
docker-machine ip
```

### Grafana default login credentials ###
```
user: admin
pass: admin
```

### Running container under boot2docker ###
```bash
docker run -d -p 80:80 -p 8083:8083 -p 8086:8086 wk/grafana-influxdb:latest
```

### Get running container ID ###
```bash
docker ps | grep wk/grafana-influxdb | awk '{print $1}'
```

### Attach to the bash console ###
```bash
docker exec -it [container-id] bash
```
