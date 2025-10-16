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
PHONE=$(bashio::config 'phone')
MAIL=$(bashio::config 'mail')
WAKE_UP_MAIL=$(bashio::config 'wake_up_mail')
OPENAI_ADDRESS=$(bashio::config 'openai_address')
OPENAI_KEY=$(bashio::config 'openai_key')
OPENAI_MODE=$(bashio::config 'openai_mode')
OPENAI_FAST_MODE=$(bashio::config 'openai_fast_mode')
FILTER_MESSAGE=$(bashio::config 'filter_message')
POETRY=$(bashio::config 'poetry')
TOO_LONG=$(bashio::config 'too_long')
IS_DISPLAY=$(bashio::config 'is_display')
DISPLAY_AREA=$(bashio::config 'display_area')

bashio::log.info "Creating hahub Client/Server configuration..."
bashio::log.info "Configuration created with following settings:"
bashio::log.info "MAIL: ${MAIL}"
bashio::log.info "PHONE: ${PHONE}"
bashio::log.info "OPENAI_MODE: ${OPENAI_MODE}"
bashio::log.info "OPENAI_FAST_MODE: ${OPENAI_FAST_MODE}"
bashio::log.info "OPENAI_ADDRESS: ${OPENAI_ADDRESS}"
bashio::log.info "OPENAI_KEY: ${OPENAI_KEY}"
bashio::log.info "FILTER_MESSAGE: ${FILTER_MESSAGE}"
bashio::log.info "POETRY: ${POETRY}"
bashio::log.info "TOO_LONG: ${TOO_LONG}"
bashio::log.info "IS_DISPLAY: ${IS_DISPLAY}"
bashio::log.info "WAKE_UP_MAIL: ${WAKE_UP_MAIL}"
bashio::log.info "DISPLAY_AREA: ${DISPLAY_AREA}"

export HASS_PHONE="${PHONE}"
export HASS_MAIL="${MAIL}"
export HASS_WAKE_UP_MAIL="${WAKE_UP_MAIL}"
export HASS_OPENAI_MODE="${OPENAI_MODE}"
export HASS_OPENAI_FAST_MODE="${OPENAI_FAST_MODE}"
export HASS_OPENAI_ADDRESS="${OPENAI_ADDRESS}"
export HASS_OPENAI_KEY="${OPENAI_KEY}"
export HASS_SERVER="http://supervisor/core"
export HASS_TOKEN="${SUPERVISOR_TOKEN:-}"
export HASS_FILTER_MESSAGE="${FILTER_MESSAGE}"
export HASS_POETRY="${POETRY}"
export HASS_TOO_LONG="${TOO_LONG}"
export HASS_IS_DISPLAY="${IS_DISPLAY}"
export HASS_DISPLAY_AREA="${DISPLAY_AREA}"

# 启动 hahub
cd /usr/src
./hahub > "${LOG_FILE}" 2>&1 & WAIT_PIDS+=($!) & tail -f ${LOG_FILE}


trap "stop_hahub" SIGTERM SIGHUP

wait "${WAIT_PIDS[@]}"