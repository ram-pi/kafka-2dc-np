# Kafka 2DC Docker Scenario 
Simulate network partition between 2 data-centers. 

In our example:
* DC-1: kafka-1, kafka-2,zookeeper-1,zookeeper-2
* DC-2: kafka-3, kafka-4,zookeeper-3

## Steps to reproduce
```
docker-compose up -d
./init.sh
./outage.sh
./failback.sh
```

### Based on [https://github.com/Dabz/kafka-boom-boom](https://github.com/Dabz/kafka-boom-boom).