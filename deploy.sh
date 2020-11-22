#!/bin/bash
# deploy updated prometheus & grafana configs to local docker config dir

# check if DOCKER env var set, otherwise stop
if [ -z ${DOCKER+x} ]; then
	echo "DOCKER environment variable is not set - terminating";
	exit 1
else
	echo "copying config to '$DOCKER/prometheus'";
fi

# build directory structure
if [ ! -d $DOCKER/prometheus ]; then
  mkdir $DOCKER/prometheus
fi

if [ ! -d $DOCKER/prometheus/prometheus ]; then
  mkdir $DOCKER/prometheus/prometheus
fi

if [ ! -d $DOCKER/prometheus/alertmanager ]; then
  mkdir $DOCKER/prometheus/alertmanager
fi

if [ ! -d $DOCKER/prometheus/dashboards ]; then
  mkdir $DOCKER/prometheus/dashboards
fi

if [ ! -d $DOCKER/prometheus/grafana ]; then
  mkdir $DOCKER/prometheus/grafana
fi

if [ ! -d $DOCKER/prometheus/mqtt2prometheus ]; then
  mkdir $DOCKER/prometheus/mqtt2prometheus
fi

# copy config files to deployment directories
cp docker-compose.yml $DOCKER/prometheus/docker-compose.yml
cp -r prometheus/* $DOCKER/prometheus/prometheus/
cp -r alertmanager/* $DOCKER/prometheus/alertmanager/
cp -r grafana/* $DOCKER/prometheus/grafana/
cp -r dashboards/* $DOCKER/prometheus/dashboards/
cp run.sh $DOCKER/prometheus/
cp stop.sh $DOCKER/prometheus/
chmod +x $DOCKER/prometheus/run.sh $DOCKER/prometheus/stop.sh


# handle per environment device config differences
case $PROM_ENV in
    dev)
        echo "Development environment device configs used"
        cp docker-compose-dev.yml $DOCKER/prometheus/docker-env.yml
        cp -r mqtt2prometheus/* $DOCKER/prometheus/mqtt2prometheus/
        ;;
    test)
        echo "Test environment device configs used"
        cp docker-compose-test.yml $DOCKER/prometheus/docker-env.yml
        cp -r mqtt2prometheus/* $DOCKER/prometheus/mqtt2prometheus/
        ;;
    prod)
        echo "Prod environment device configs used"
        cp docker-compose-prod.yml $DOCKER/prometheus/docker-env.yml
        cp -r mqtt2prometheus/* $DOCKER/prometheus/mqtt2prometheus/
        ;;
    *)
        echo "No per-environment device configs enabled: set PROM_ENV accordingly"
        exit 1
esac

