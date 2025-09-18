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

bashio::log.info "Creating hahub Client/Server configuration..."
bashio::log.info "Configuration created with following settings:"
bashio::log.info "PHONE: ${PHONE}"
bashio::log.info "OPENAI_KEY: ${OPENAI_KEY}"

# 创建 TOML 配置文件
cat > "${CONFIG_PATH}" << EOL
phone = "${PHONE}"
openai_key = "${OPENAI_KEY}"
EOL

cat $CONFIG_PATH

# 检查配置文件是否存在
if [ ! -f "${CONFIG_PATH}" ]; then
    bashio::log.error "Configuration file not found at ${CONFIG_PATH}"
    exit 1
fi

export HASS_PHONE = "${PHONE}"
export HASS_SERVER="http://supervisor/core"
export HASS_TOKEN="${SUPERVISOR_TOKEN:-}"

# 启动 hahub
bashio::log.info "Starting hahub Client/Server with configuration at ${CONFIG_PATH}"
cd /usr/src
./hahub -c $CONFIG_PATH > "${LOG_FILE}" 2>&1 & WAIT_PIDS+=($!) & tail -f ${LOG_FILE}



trap "stop_hahub" SIGTERM SIGHUP

wait "${WAIT_PIDS[@]}"