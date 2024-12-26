#!/bin/bash

# Redis集群配置
PASSWORD="zXiXr76ZZgHt3frqgtTYcDQkmsXATFCA"
START_PORT=8701
END_PORT=8706

# 输出Redis实例启动命令
echo "# 启动Redis实例命令"
for PORT in $(seq $START_PORT $END_PORT); do
    CONFIG_FILE="redis_$PORT.conf"
    DATA_DIR="./data/$PORT"
    # 删除旧的配置文件
    rm -f $CONFIG_FILE
    mkdir -p $DATA_DIR
    cat > $CONFIG_FILE <<EOF
port $PORT
cluster-enabled yes
cluster-config-file nodes-$PORT.conf
cluster-node-timeout 5000
appendonly yes
dir $DATA_DIR
requirepass $PASSWORD
masterauth $PASSWORD
daemonize yes
EOF
    echo "redis-server $CONFIG_FILE &"
done

# 输出创建集群的命令
echo "# 创建集群命令"
HOST=127.0.0.1
NODES=""
for PORT in $(seq $START_PORT $END_PORT); do
    NODES+="$HOST:$PORT "
done

# 去掉末尾的空格
NODES=${NODES% }

echo "redis-cli --cluster create $NODES --cluster-replicas 1 -a $PASSWORD"
