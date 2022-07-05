#! /bin/sh
#
# clean.sh

source $(pwd)/utils.sh

unblock_all
sleep 5
docker exec kafka-1 bash -c "kafka-leader-election --election-type preferred --bootstrap-server localhost:9092 --all-topic-partitions"
sleep 5 
zookeeper_mode zookeeper-1 zookeeper-2 zookeeper-3