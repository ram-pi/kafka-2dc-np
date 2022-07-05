#! /bin/sh
#
# utils.sh

interface=eth0

container_to_ip() {
    echo $(docker exec $1 hostname -I)
}

block_host() {
    name=$1
    shift 1
    docker exec -u0 $name tc qdisc del dev $interface root > /dev/null 2>&1
    docker exec -u0 $name tc qdisc add dev $interface root handle 1: prio
    docker exec -u0 $name tc qdisc add dev $interface parent 1:3 handle 10: netem loss 100%
    for ip in $@; do
        docker exec -u0 $name tc filter add dev eth0 protocol ip parent 1:0 prio 3 u32 match ip dst $ip/32 flowid 1:3
    done
}

block_host_completely() {
    name=$1
    shift 1
    docker exec -u0 $name tc qdisc del dev eth0 root > /dev/null 2>&1
    docker exec -u0 $name tc qdisc add dev eth0 root handle 1: prio
    docker exec -u0 $name tc qdisc add dev eth0 parent 1:3 handle 10: netem loss 100%
    docker exec -u0 $name tc filter add dev eth0 protocol ip parent 1:0 prio 3 u32 match ip dst 0.0.0.0/0 flowid 1:3
}

unblock_host() {
    name=$1
    shift 1
    # https://serverfault.com/a/906499
    docker exec -u0 $name tc qdisc del dev eth0 root > /dev/null 2>&1
}

unblock_all() {
    unblock_host zookeeper-1
    unblock_host zookeeper-2
    unblock_host zookeeper-3
    unblock_host kafka-1
    unblock_host kafka-2
    unblock_host kafka-3
    unblock_host kafka-4
}

zookeeper_mode() {
    for container in $@; do
        name=$container
        mode=$(docker exec -t $name bash -c "echo stat | nc localhost 2181 | grep Mode")

        if [ $? -eq 0 ]; then
            echo "$container $mode"
        else
            echo "$container has no mode"
        fi
    done
}