source $(pwd)/utils.sh

echo "Delete topic test..."
kafka-topics --bootstrap-server localhost:9091,localhost:29092,localhost:9093,localhost:9094 --topic test --delete