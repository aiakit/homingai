#!/usr/bin/with-contenv bashio

set -e

# 定义配置文件路径
LOG_FILE="/data/hahub.log"
APP_PATH="/usr/src"
WAIT_PIDS=()

function stop_hahub() {
    bashio::log.info "Stop hahub"
    kill -15 "${WAIT_PIDS[@]}"
}


# 检查 hahub 是否存在
if [ ! -f "${APP_PATH}/hahub" ]; then
    bashio::log.error "hahub Client binary not found at ${APP_PATH}/hahub"
    exit 1
fi

# 确保二进制文件可执行
chmod +x "${APP_PATH}/hahub"

# 从 Home Assistant 配置中获取值
MAIL=$(bashio::config 'mail')
SPEAKERS=$(bashio::config 'speakers')
OPENAI_ADDRESS=$(bashio::config 'openai_address')
OPENAI_KEY=$(bashio::config 'openai_key')

bashio::log.info "Creating hahub Client/Server configuration..."
bashio::log.info "Configuration created with following settings:"
bashio::log.info "MAIL: ${MAIL}"
bashio::log.info "SPEAKERS: ${SPEAKERS}"

export HASS_MAIL="${MAIL}"
export HASS_SPEAKERS="${SPEAKERS}"
export HASS_OPENAI_ADDRESS="${OPENAI_ADDRESS}"
export HASS_OPENAI_KEY="${OPENAI_KEY}"
export HASS_SERVER="http://supervisor/core"
export HASS_TOKEN="${SUPERVISOR_TOKEN:-}"

# 启动 hahub
cd /usr/src
./hahub > "${LOG_FILE}" 2>&1 & WAIT_PIDS+=($!) & tail -f ${LOG_FILE}


trap "stop_hahub" SIGTERM SIGHUP

wait "${WAIT_PIDS[@]}"