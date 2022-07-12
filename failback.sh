#! /bin/sh
#
# clean.sh

source $(pwd)/utils.sh

unblock_all
sleep 30
docker exec kafka-1 bash -c "kafka-leader-election --election-type preferred --bootstrap-server localhost:9092 --all-topic-partitions"
sleep 5
zookeeper_mode zookeeper-1 zookeeper-2 zookeeper-3
sleep 5
echo "Topic describe..."
kafka-topics --bootstrap-server localhost:9091,localhost:29092,localhost:9093,localhost:9094 --describe --topic test