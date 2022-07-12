#! /bin/sh
#
# outage.sh
# Block traffic from kafka-3,kafka-4,zookeeper-3 to kafka-1,kafka-2,zookeeper-1,zookeeper-2
# DC-1: kafka-1,kafka-2,zookeeper-1,zookeeper-2
# DC-2: kafka-3,kafka-4,zookeeper-3

source $(pwd)/utils.sh

KAFKA_1_IP=$(container_to_ip kafka-1)
KAFKA_2_IP=$(container_to_ip kafka-2)
KAFKA_3_IP=$(container_to_ip kafka-3)
KAFKA_4_IP=$(container_to_ip kafka-4)
ZOO_1_IP=$(container_to_ip zookeeper-1)
ZOO_2_IP=$(container_to_ip zookeeper-2)
ZOO_3_IP=$(container_to_ip zookeeper-3)
interface=eth0

# Network Partition
block_host kafka-3 $ZOO_1_IP $ZOO_2_IP $KAFKA_1_IP $KAFKA_2_IP
block_host kafka-4 $ZOO_1_IP $ZOO_2_IP $KAFKA_1_IP $KAFKA_2_IP
block_host zookeeper-3 $ZOO_1_IP $ZOO_2_IP $KAFKA_1_IP $KAFKA_2_IP

SLEEP_TIME="30"
echo "Current time: $(date +%T)"
echo "Waiting for ${SLEEP_TIME} seconds ..."
sleep ${SLEEP_TIME}
echo "Current time: $(date +%T)"

echo "Zookeeper status"
zookeeper_mode zookeeper-1 zookeeper-2 zookeeper-3

sleep 5

echo "Topic describe..."
kafka-topics --bootstrap-server localhost:9091 --describe --topic test
#docker exec kafka-1 bash -c "kafka-topics --bootstrap-server kafka-1:9092,kafka-2:9092,kafka-3:9092,kafka-4:9092 --describe --topic test"

echo "Producing from broker-1 (DC-1)..."
docker exec kafka-1 bash -c "echo broker-1 $(date) | kafka-console-producer --bootstrap-server localhost:9092 --topic test --request-required-acks -1"
echo "Producing from broker-2 (DC-1)..."
docker exec kafka-2 bash -c "echo broker-2 $(date) | kafka-console-producer --bootstrap-server localhost:9092 --topic test --request-required-acks -1"
echo "Producing from broker-3 (DC-2)..."
docker exec kafka-3 bash -c "echo broker-3 $(date) | kafka-console-producer --bootstrap-server localhost:9092 --topic test --request-required-acks -1"
echo "Producing from broker-4 (DC-2)..."
docker exec kafka-4 bash -c "echo broker-4 $(date) | kafka-console-producer --bootstrap-server localhost:9092 --topic test --request-required-acks -1"

echo "Consuming from broker-1 (DC-1)..."
docker exec kafka-1 bash -c "kafka-console-consumer --bootstrap-server localhost:9092 --topic test --from-beginning --timeout-ms 10000"
echo "Consuming from broker-3 (DC-2)..."
docker exec kafka-3 bash -c "kafka-console-consumer --bootstrap-server localhost:9092 --topic test --from-beginning --timeout-ms 10000"
echo "Consuming from host..."
kafka-console-consumer --bootstrap-server localhost:9091,localhost:29092,localhost:9093,localhost:9094 --topic test --from-beginning --timeout-ms 5000