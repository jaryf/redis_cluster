#!/bin/bash

# Redis集群配置
PASSWORD="zXiXr76ZZgHt3frqgtTYcDQkmsXATFCA"
START_PORT=8701
END_PORT=8706
HOST=127.0.0.1

# 写入所有Redis配置文件的函数
write_configs() {
    for PORT in $(seq $START_PORT $END_PORT); do
        local CONFIG_FILE="redis_$PORT.conf"
        local DATA_DIR="./data/$PORT"

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
        echo "生成配置文件：$CONFIG_FILE"
    done
}

# 启动所有Redis实例的函数
start_redis() {
    for PORT in $(seq $START_PORT $END_PORT); do
        local CONFIG_FILE="redis_$PORT.conf"
        echo "启动 Redis 实例：端口 $PORT"
        redis-server $CONFIG_FILE &
    done
}

# 创建集群的函数
create_cluster() {
    local NODES=""

    for PORT in $(seq $START_PORT $END_PORT); do
        NODES+="$HOST:$PORT "
    done

    # 去掉末尾的空格
    NODES=${NODES% }

    echo "创建集群命令："
    echo "redis-cli --cluster create $NODES --cluster-replicas 1 -a $PASSWORD"
    redis-cli --cluster create $NODES --cluster-replicas 1 -a $PASSWORD
}

# 初始化所有操作的函数
init_all() {
    echo "初始化：生成配置文件、启动实例并创建集群..."
    write_configs
    start_redis
    create_cluster
}

# 显示帮助信息的函数
show_help() {
    echo "使用方法：$0 {config|start|cluster|init|help}"
    echo "  config  - 生成所有Redis配置文件"
    echo "  start   - 启动所有Redis实例"
    echo "  cluster - 创建Redis集群"
    echo "  init    - 执行所有操作（生成配置、启动实例、创建集群）"
    echo "  help    - 显示帮助信息"
}

# 主程序
if [[ $# -eq 0 ]]; then
    show_help
    exit 1
fi

case $1 in
    config)
        echo "生成配置文件..."
        write_configs
        ;;
    start)
        echo "启动Redis实例..."
        start_redis
        ;;
    cluster)
        echo "创建Redis集群..."
        create_cluster
        ;;
    init)
        echo "执行所有操作..."
        init_all
        ;;
    help)
        show_help
        ;;
    *)
        echo "未知命令：$1"
        show_help
        exit 1
        ;;
esac
