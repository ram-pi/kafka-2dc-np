#! /bin/sh
#
# init.sh
# Create topic and produce some data

source $(pwd)/utils.sh

# Install TC (Traffic Control)
docker exec -u0 -d kafka-1 bash -c "yum install -y libmnl iptables which" 
docker exec -u0 -d kafka-1 bash -c "rpm -i --nodeps --nosignature http://vault.centos.org/8.1.1911/BaseOS/x86_64/os/Packages/iproute-tc-4.18.0-15.el8.x86_64.rpm"
docker exec -u0 -d kafka-2 bash -c "yum install -y libmnl iptables which"
docker exec -u0 -d kafka-2 bash -c "rpm -i --nodeps --nosignature http://vault.centos.org/8.1.1911/BaseOS/x86_64/os/Packages/iproute-tc-4.18.0-15.el8.x86_64.rpm"
docker exec -u0 -d kafka-3 bash -c "yum install -y libmnl iptables which"
docker exec -u0 -d kafka-3 bash -c "rpm -i --nodeps --nosignature http://vault.centos.org/8.1.1911/BaseOS/x86_64/os/Packages/iproute-tc-4.18.0-15.el8.x86_64.rpm"
docker exec -u0 -d kafka-4 bash -c "yum install -y libmnl iptables which"
docker exec -u0 -d kafka-4 bash -c "rpm -i --nodeps --nosignature http://vault.centos.org/8.1.1911/BaseOS/x86_64/os/Packages/iproute-tc-4.18.0-15.el8.x86_64.rpm"
docker exec -u0 -d zookeeper-1 bash -c "yum install -y libmnl iptables which"
docker exec -u0 -d zookeeper-1 bash -c "rpm -i --nodeps --nosignature http://vault.centos.org/8.1.1911/BaseOS/x86_64/os/Packages/iproute-tc-4.18.0-15.el8.x86_64.rpm"
docker exec -u0 -d zookeeper-2 bash -c "yum install -y libmnl iptables which"
docker exec -u0 -d zookeeper-2 bash -c "rpm -i --nodeps --nosignature http://vault.centos.org/8.1.1911/BaseOS/x86_64/os/Packages/iproute-tc-4.18.0-15.el8.x86_64.rpm"
docker exec -u0 -d zookeeper-3 bash -c "yum install -y libmnl iptables which"
docker exec -u0 -d zookeeper-3 bash -c "rpm -i --nodeps --nosignature http://vault.centos.org/8.1.1911/BaseOS/x86_64/os/Packages/iproute-tc-4.18.0-15.el8.x86_64.rpm"

sleep 5

docker exec kafka-1 bash -c "kafka-topics --bootstrap-server kafka-1:9092,kafka-2:9092,kafka-3:9092,kafka-4:9092 --create --topic test --config min.insync.replicas=2 --replica-assignment 3:4:2:1"

docker exec kafka-1 bash -c "kafka-topics --bootstrap-server kafka-1:9092,kafka-2:9092,kafka-3:9092,kafka-4:9092 --describe --topic test"

echo "Producing from broker-1 (DC-1)..."
docker exec kafka-1 bash -c "echo broker-1 $(date) | kafka-console-producer --bootstrap-server localhost:9092 --topic test --request-required-acks -1"
echo "Producing from broker-2 (DC-1)..."
docker exec kafka-2 bash -c "echo broker-2 $(date) | kafka-console-producer --bootstrap-server localhost:9092 --topic test --request-required-acks -1"
echo "Producing from broker-3 (DC-2)..."
docker exec kafka-3 bash -c "echo broker-3 $(date) | kafka-console-producer --bootstrap-server localhost:9092 --topic test --request-required-acks -1"
echo "Producing from broker-4 (DC-2)..."
docker exec kafka-4 bash -c "echo broker-4 $(date) | kafka-console-producer --bootstrap-server localhost:9092 --topic test --request-required-acks -1"

echo "Consuming from broker 1 (DC-1)..."
docker exec kafka-1 bash -c "kafka-console-consumer --bootstrap-server localhost:9092 --topic test --from-beginning --timeout-ms 5000"
echo "Consuming from broker 3 (DC-2)..."
docker exec kafka-3 bash -c "kafka-console-consumer --bootstrap-server localhost:9092 --topic test --from-beginning --timeout-ms 5000"
echo "Consuming from host..."
kafka-console-consumer --bootstrap-server localhost:9091,localhost:29092,localhost:9093,localhost:9094 --topic test --from-beginning --timeout-ms 5000

echo "Zookeeper status..."
zookeeper_mode zookeeper-1 zookeeper-2 zookeeper-3