#!/usr/bin/with-contenv bashio

set -e

# 定义配置文件路径
CONFIG_PATH=/data/hahub.toml
LOG_FILE="/data/hahub.log"
APP_PATH="/usr/src"
WAIT_PIDS=()

function stop_hahub() {
    bashio::log.info "Stop hahub"
    kill -15 "${WAIT_PIDS[@]}"
}

if [ -f "${CONFIG_PATH}" ]; then
    bashio::log.info "Removing old configuration file..."
    rm -f "${CONFIG_PATH}"
fi

# 显示欢迎信息
ALL_CONFIG=$(bashio::config --all)
bashio::log.info "Starting hahub Client...${ALL_CONFIG}"

cat /data/options.json

# 检查 hahub 是否存在
if [ ! -f "${APP_PATH}/hahub" ]; then
    bashio::log.error "hahub Client binary not found at ${APP_PATH}/hahub"
    exit 1
fi

# 确保二进制文件可执行
chmod +x "${APP_PATH}/hahub"

# 从 Home Assistant 配置中获取值
PHONE=$(bashio::config 'phone')
PASSWORD=$(bashio::config 'password')
OPENAI_KEY=$(bashio::config 'openai_key')
AUTH_TOKEN=$(bashio::config 'auth_token')

bashio::log.info "Creating hahub Client/Server configuration..."
bashio::log.info "Configuration created with following settings:"
bashio::log.info "Phone: ${PHONE}"
bashio::log.info "Proxy Name: ${PASSWORD}"

# 创建 TOML 配置文件
cat > "${CONFIG_PATH}" << EOL
phone = "${PHONE}"
password = ${PASSWORD}
openai_key = "${OPENAI_KEY}"
auth_token = "${AUTH_TOKEN}"
EOL

cat $CONFIG_PATH

# 检查配置文件是否存在
if [ ! -f "${CONFIG_PATH}" ]; then
    bashio::log.error "Configuration file not found at ${CONFIG_PATH}"
    exit 1
fi

# 启动 hahub
bashio::log.info "Starting hahub Client/Server with configuration at ${CONFIG_PATH}"
cd /usr/src
./hahub -c $CONFIG_PATH > "${LOG_FILE}" 2>&1 & WAIT_PIDS+=($!) & tail -f ${LOG_FILE}

# 生成 Nginx 配置文件
cat <<EOF > /etc/nginx/conf.d/default.conf
server {
    listen 80;

    location / {
        proxy_pass http://127.0.0.1:7999/index.html;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket 支持
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

# 启动 Nginx
nginx -g "daemon off;" &

trap "stop_hahub" SIGTERM SIGHUP

wait "${WAIT_PIDS[@]}"