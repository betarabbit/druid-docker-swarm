# Docker Image for Druid
Druid can be complex to setup. This image will have you running Druid as a Docker swarm cluster in just a few munites.

## Quick Start
```
docker stack deploy -c docker-stack.yml --with-registry-auth druid
```
This starts a Druid cluster base Docker swarm.
> Assuming you have already built images and push them to a registry.

Please note that Druid cluster requires a lot of resources, make sure you have enough resources before kicking it off.

## Includes following components
- Zookeeper
- PostgresSQL
- Broker
- Coordinator
- Historical
- MiddleManager
- Overlord
- Tranquility

## Mapped Ports
Host | Container | Service
---- | --------- | -------------------------------
2181, 2182, 2183 | 2181, 2182, 2183 | Zookeeper
5432 | 5432 | PostgresSQL
8082 | 8082 | Broker
8081 | 8081 | Coordinator
8083 | 8083 | Historical
8090 | 8090 | Overlord
8200 | 8200 | Tranquility

Of course you can remap container port to any host port freely, you don't even need to map all of them, map required ports only.


